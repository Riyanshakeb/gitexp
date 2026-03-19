package com.azizgraphics.clcltr.data.db

import androidx.lifecycle.LiveData
import androidx.room.*
import com.azizgraphics.clcltr.data.model.Material

@Dao
interface MaterialDao {
    @Query("SELECT * FROM materials ORDER BY name ASC")
    fun getAllMaterials(): LiveData<List<Material>>

    @Query("SELECT * FROM materials ORDER BY name ASC")
    suspend fun getAllMaterialsList(): List<Material>

    @Insert
    suspend fun insert(material: Material): Long

    @Update
    suspend fun update(material: Material)

    @Delete
    suspend fun delete(material: Material)
}
