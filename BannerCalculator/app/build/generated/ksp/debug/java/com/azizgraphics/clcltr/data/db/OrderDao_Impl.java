package com.azizgraphics.clcltr.data.db;

import android.database.Cursor;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.LiveData;
import androidx.room.CoroutinesRoom;
import androidx.room.EntityDeletionOrUpdateAdapter;
import androidx.room.EntityInsertionAdapter;
import androidx.room.RoomDatabase;
import androidx.room.RoomSQLiteQuery;
import androidx.room.SharedSQLiteStatement;
import androidx.room.util.CursorUtil;
import androidx.room.util.DBUtil;
import androidx.sqlite.db.SupportSQLiteStatement;
import com.azizgraphics.clcltr.data.model.Order;
import java.lang.Class;
import java.lang.Exception;
import java.lang.Long;
import java.lang.Object;
import java.lang.Override;
import java.lang.String;
import java.lang.SuppressWarnings;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.Callable;
import javax.annotation.processing.Generated;
import kotlin.Unit;
import kotlin.coroutines.Continuation;

@Generated("androidx.room.RoomProcessor")
@SuppressWarnings({"unchecked", "deprecation"})
public final class OrderDao_Impl implements OrderDao {
  private final RoomDatabase __db;

  private final EntityInsertionAdapter<Order> __insertionAdapterOfOrder;

  private final EntityDeletionOrUpdateAdapter<Order> __deletionAdapterOfOrder;

  private final EntityDeletionOrUpdateAdapter<Order> __updateAdapterOfOrder;

  private final SharedSQLiteStatement __preparedStmtOfDeleteAll;

  public OrderDao_Impl(@NonNull final RoomDatabase __db) {
    this.__db = __db;
    this.__insertionAdapterOfOrder = new EntityInsertionAdapter<Order>(__db) {
      @Override
      @NonNull
      protected String createQuery() {
        return "INSERT OR ABORT INTO `orders` (`id`,`projectName`,`itemsJson`,`totalAmount`,`totalQuantity`,`totalSqft`,`currency`,`createdAt`) VALUES (nullif(?, 0),?,?,?,?,?,?,?)";
      }

      @Override
      protected void bind(@NonNull final SupportSQLiteStatement statement,
          @NonNull final Order entity) {
        statement.bindLong(1, entity.getId());
        statement.bindString(2, entity.getProjectName());
        statement.bindString(3, entity.getItemsJson());
        statement.bindDouble(4, entity.getTotalAmount());
        statement.bindLong(5, entity.getTotalQuantity());
        statement.bindDouble(6, entity.getTotalSqft());
        statement.bindString(7, entity.getCurrency());
        statement.bindLong(8, entity.getCreatedAt());
      }
    };
    this.__deletionAdapterOfOrder = new EntityDeletionOrUpdateAdapter<Order>(__db) {
      @Override
      @NonNull
      protected String createQuery() {
        return "DELETE FROM `orders` WHERE `id` = ?";
      }

      @Override
      protected void bind(@NonNull final SupportSQLiteStatement statement,
          @NonNull final Order entity) {
        statement.bindLong(1, entity.getId());
      }
    };
    this.__updateAdapterOfOrder = new EntityDeletionOrUpdateAdapter<Order>(__db) {
      @Override
      @NonNull
      protected String createQuery() {
        return "UPDATE OR ABORT `orders` SET `id` = ?,`projectName` = ?,`itemsJson` = ?,`totalAmount` = ?,`totalQuantity` = ?,`totalSqft` = ?,`currency` = ?,`createdAt` = ? WHERE `id` = ?";
      }

      @Override
      protected void bind(@NonNull final SupportSQLiteStatement statement,
          @NonNull final Order entity) {
        statement.bindLong(1, entity.getId());
        statement.bindString(2, entity.getProjectName());
        statement.bindString(3, entity.getItemsJson());
        statement.bindDouble(4, entity.getTotalAmount());
        statement.bindLong(5, entity.getTotalQuantity());
        statement.bindDouble(6, entity.getTotalSqft());
        statement.bindString(7, entity.getCurrency());
        statement.bindLong(8, entity.getCreatedAt());
        statement.bindLong(9, entity.getId());
      }
    };
    this.__preparedStmtOfDeleteAll = new SharedSQLiteStatement(__db) {
      @Override
      @NonNull
      public String createQuery() {
        final String _query = "DELETE FROM orders";
        return _query;
      }
    };
  }

  @Override
  public Object insert(final Order order, final Continuation<? super Long> $completion) {
    return CoroutinesRoom.execute(__db, true, new Callable<Long>() {
      @Override
      @NonNull
      public Long call() throws Exception {
        __db.beginTransaction();
        try {
          final Long _result = __insertionAdapterOfOrder.insertAndReturnId(order);
          __db.setTransactionSuccessful();
          return _result;
        } finally {
          __db.endTransaction();
        }
      }
    }, $completion);
  }

  @Override
  public Object delete(final Order order, final Continuation<? super Unit> $completion) {
    return CoroutinesRoom.execute(__db, true, new Callable<Unit>() {
      @Override
      @NonNull
      public Unit call() throws Exception {
        __db.beginTransaction();
        try {
          __deletionAdapterOfOrder.handle(order);
          __db.setTransactionSuccessful();
          return Unit.INSTANCE;
        } finally {
          __db.endTransaction();
        }
      }
    }, $completion);
  }

  @Override
  public Object update(final Order order, final Continuation<? super Unit> $completion) {
    return CoroutinesRoom.execute(__db, true, new Callable<Unit>() {
      @Override
      @NonNull
      public Unit call() throws Exception {
        __db.beginTransaction();
        try {
          __updateAdapterOfOrder.handle(order);
          __db.setTransactionSuccessful();
          return Unit.INSTANCE;
        } finally {
          __db.endTransaction();
        }
      }
    }, $completion);
  }

  @Override
  public Object deleteAll(final Continuation<? super Unit> $completion) {
    return CoroutinesRoom.execute(__db, true, new Callable<Unit>() {
      @Override
      @NonNull
      public Unit call() throws Exception {
        final SupportSQLiteStatement _stmt = __preparedStmtOfDeleteAll.acquire();
        try {
          __db.beginTransaction();
          try {
            _stmt.executeUpdateDelete();
            __db.setTransactionSuccessful();
            return Unit.INSTANCE;
          } finally {
            __db.endTransaction();
          }
        } finally {
          __preparedStmtOfDeleteAll.release(_stmt);
        }
      }
    }, $completion);
  }

  @Override
  public LiveData<List<Order>> getAllOrders() {
    final String _sql = "SELECT * FROM orders ORDER BY createdAt DESC";
    final RoomSQLiteQuery _statement = RoomSQLiteQuery.acquire(_sql, 0);
    return __db.getInvalidationTracker().createLiveData(new String[] {"orders"}, false, new Callable<List<Order>>() {
      @Override
      @Nullable
      public List<Order> call() throws Exception {
        final Cursor _cursor = DBUtil.query(__db, _statement, false, null);
        try {
          final int _cursorIndexOfId = CursorUtil.getColumnIndexOrThrow(_cursor, "id");
          final int _cursorIndexOfProjectName = CursorUtil.getColumnIndexOrThrow(_cursor, "projectName");
          final int _cursorIndexOfItemsJson = CursorUtil.getColumnIndexOrThrow(_cursor, "itemsJson");
          final int _cursorIndexOfTotalAmount = CursorUtil.getColumnIndexOrThrow(_cursor, "totalAmount");
          final int _cursorIndexOfTotalQuantity = CursorUtil.getColumnIndexOrThrow(_cursor, "totalQuantity");
          final int _cursorIndexOfTotalSqft = CursorUtil.getColumnIndexOrThrow(_cursor, "totalSqft");
          final int _cursorIndexOfCurrency = CursorUtil.getColumnIndexOrThrow(_cursor, "currency");
          final int _cursorIndexOfCreatedAt = CursorUtil.getColumnIndexOrThrow(_cursor, "createdAt");
          final List<Order> _result = new ArrayList<Order>(_cursor.getCount());
          while (_cursor.moveToNext()) {
            final Order _item;
            final long _tmpId;
            _tmpId = _cursor.getLong(_cursorIndexOfId);
            final String _tmpProjectName;
            _tmpProjectName = _cursor.getString(_cursorIndexOfProjectName);
            final String _tmpItemsJson;
            _tmpItemsJson = _cursor.getString(_cursorIndexOfItemsJson);
            final double _tmpTotalAmount;
            _tmpTotalAmount = _cursor.getDouble(_cursorIndexOfTotalAmount);
            final int _tmpTotalQuantity;
            _tmpTotalQuantity = _cursor.getInt(_cursorIndexOfTotalQuantity);
            final double _tmpTotalSqft;
            _tmpTotalSqft = _cursor.getDouble(_cursorIndexOfTotalSqft);
            final String _tmpCurrency;
            _tmpCurrency = _cursor.getString(_cursorIndexOfCurrency);
            final long _tmpCreatedAt;
            _tmpCreatedAt = _cursor.getLong(_cursorIndexOfCreatedAt);
            _item = new Order(_tmpId,_tmpProjectName,_tmpItemsJson,_tmpTotalAmount,_tmpTotalQuantity,_tmpTotalSqft,_tmpCurrency,_tmpCreatedAt);
            _result.add(_item);
          }
          return _result;
        } finally {
          _cursor.close();
        }
      }

      @Override
      protected void finalize() {
        _statement.release();
      }
    });
  }

  @NonNull
  public static List<Class<?>> getRequiredConverters() {
    return Collections.emptyList();
  }
}
