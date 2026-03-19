package com.azizgraphics.clcltr.data.db

import androidx.lifecycle.LiveData
import androidx.room.*
import com.azizgraphics.clcltr.data.model.Order

@Dao
interface OrderDao {
    @Query("SELECT * FROM orders ORDER BY createdAt DESC")
    fun getAllOrders(): LiveData<List<Order>>

    @Insert
    suspend fun insert(order: Order): Long

    @Update
    suspend fun update(order: Order)

    @Delete
    suspend fun delete(order: Order)

    @Query("DELETE FROM orders")
    suspend fun deleteAll()
}
