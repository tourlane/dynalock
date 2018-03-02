require 'aws-sdk-dynamodb'

module Dynalock
  module Lock
    class Locked < Exception ; end
    def acquire_lock(context:, owner: lock_default_owner, table: "locks", expire_time: 10)
      dynamodb_client.put_item(
	table_name: table,
	item: {
	  id: context,
	  lock_owner: owner,
	  expires: Time.now.utc.to_i + expire_time
	},
	condition_expression: "attribute_not_exists(expires) OR expires < :expires",
	expression_attribute_values: {
	  ":expires": Time.now.utc.to_i
	}
      )
      true
    rescue Aws::DynamoDB::Errors::ConditionalCheckFailedException
      return false
    end

    def refresh_lock(context:, owner: lock_default_owner, table: "locks", expire_time: 10)
      dynamodb_client.update_item({
	table_name: table,
	key: { id: context },
	update_expression: "SET expires = :expires",
	condition_expression: "attribute_exists(expires) AND expires > :now AND lock_owner = :owner",
	expression_attribute_values: {
	  ":expires": Time.now.utc.to_i + expire_time,
	  ":owner": owner,
	  ":now": Time.now.utc.to_i
	},
      })
      true
    rescue Aws::DynamoDB::Errors::ConditionalCheckFailedException
      return false
    end

    def with_lock(context:, owner: lock_default_owner, table: "locks")
      expire_time = 5

      result = acquire_lock(context: context, owner: owner, table: table, expire_time: expire_time)
      raise Locked.new if result == false

      thread = Thread.new {
	loop do
	  refresh_lock(context: context, owner: owner, table: table, expire_time: expire_time)
	  sleep(expire_time / 2.0)
	end
      }
      if block_given?
	return yield
      end
    ensure
      thread.kill unless thread.nil?
    end

   private

   def lock_default_owner
     @lock_default_owner ||= "#{ENV["USER"]}@#{`hostname`.strip}"
   end

    def dynamodb_client
      Aws::DynamoDB::Client.new
    end

  end
end
