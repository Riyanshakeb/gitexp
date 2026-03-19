package com.azizgraphics.clcltr.data.db

import androidx.lifecycle.LiveData
import androidx.room.*
import com.azizgraphics.clcltr.data.model.Customer

@Dao
interface CustomerDao {
    @Query("SELECT * FROM customers ORDER BY name ASC")
    fun getAllCustomers(): LiveData<List<Customer>>

    @Insert
    suspend fun insert(customer: Customer): Long

    @Update
    suspend fun update(customer: Customer)

    @Delete
    suspend fun delete(customer: Customer)
}
