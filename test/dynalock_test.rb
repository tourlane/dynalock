require "test_helper"

class DynalockTest < Minitest::Test
  include Dynalock::Lock

  def setup
    @owner = "#{ENV["USER"]}@#{`hostname`.strip}"
  end

  TABLE="test"


  def test_acquire_lock
    ctx = "test_1"
    delete(ctx)
    assert_nil get(ctx), "Environment should be clean"
    assert_equal true, acquire_lock(table: TABLE, owner: @owner, context: ctx, expire_time: 1), "Can't acquire lock"
    refute_nil get(ctx), "Lock should exists"

    assert_equal false, acquire_lock(table: TABLE, owner: @owner, context: ctx, expire_time: 1), "Was able to acquire lock while being lock"

    sleep 2

    assert_equal true, acquire_lock(table: TABLE, owner: @owner, context: ctx, expire_time: 1), "Lock is should not exists"
  ensure
    delete(ctx)
  end

  def test_refresh_token
    ctx = "test_2"
    delete(ctx)

    assert_equal true, acquire_lock(table: TABLE, owner: @owner, context: ctx, expire_time: 1), "We should be able to pick the token"
    assert_equal false, acquire_lock(table: TABLE, owner: @owner, context: ctx, expire_time: 1), "Lock should exists ASDFASDFASDF"
    assert_equal true, refresh_lock(table: TABLE, owner: @owner, context: ctx, expire_time: 3), "Token should be refresh"

    sleep 2

    assert_equal false, acquire_lock(table: TABLE, owner: @owner, context: ctx, expire_time: 1), "Lock should exists"

    sleep 2

    assert_equal true, acquire_lock(table: TABLE, owner: @owner, context: ctx, expire_time: 1), "Lock is should not exists"

  ensure
    delete(ctx)
  end

  def test_refresh_token2
    ctx = "test_3"

    assert_equal false, refresh_lock(table: TABLE, owner: @owner, context: ctx, expire_time: 3), "Should not be possible to refresh a non existing token"


    acquire_lock(table: TABLE, owner: @owner, context: ctx, expire_time: 1)
    assert_equal true, refresh_lock(table: TABLE, owner: @owner, context: ctx, expire_time: 1)
    assert_equal false, refresh_lock(table: TABLE, owner: "superman", context: ctx, expire_time: 3), "superman should not pick the lock"
    sleep 2
    assert_equal false, refresh_lock(table: TABLE, owner: @owner, context: ctx, expire_time: 1), "should not pick the lock if the lock is expired"
  ensure
    delete(ctx)
  end

  def test_with_lock
    ctx = "test_4"

    result = with_lock(context: ctx, table: TABLE) do
      assert_raises Locked do
	with_lock(context: ctx, table: TABLE)
      end
      "it run"
    end

    assert_equal "it run", result
  end


  def get(name)
    client.get_item(key:{id: name}, table_name: TABLE).item
  end

  def client
    Aws::DynamoDB::Client.new
  end

  def delete(name)
    client.delete_item(
      key: {
	id: name
      },
      table_name: TABLE
    )
  end
end
