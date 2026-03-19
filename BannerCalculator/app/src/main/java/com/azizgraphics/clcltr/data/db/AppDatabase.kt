package com.azizgraphics.clcltr.data.db

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import com.azizgraphics.clcltr.data.model.Customer
import com.azizgraphics.clcltr.data.model.Material
import com.azizgraphics.clcltr.data.model.Order

@Database(entities = [Order::class, Material::class, Customer::class], version = 1, exportSchema = false)
abstract class AppDatabase : RoomDatabase() {
    abstract fun orderDao(): OrderDao
    abstract fun materialDao(): MaterialDao
    abstract fun customerDao(): CustomerDao

    companion object {
        @Volatile
        private var INSTANCE: AppDatabase? = null

        fun getDatabase(context: Context): AppDatabase {
            return INSTANCE ?: synchronized(this) {
                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    AppDatabase::class.java,
                    "banner_calculator_db"
                ).build()
                INSTANCE = instance
                instance
            }
        }
    }
}
