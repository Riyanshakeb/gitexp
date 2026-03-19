package com.azizgraphics.clcltr.data.repository

import com.azizgraphics.clcltr.data.db.AppDatabase
import com.azizgraphics.clcltr.data.model.Customer
import com.azizgraphics.clcltr.data.model.Material
import com.azizgraphics.clcltr.data.model.Order

class AppRepository(private val db: AppDatabase) {
    val allOrders = db.orderDao().getAllOrders()
    val allMaterials = db.materialDao().getAllMaterials()
    val allCustomers = db.customerDao().getAllCustomers()

    suspend fun insertOrder(order: Order) = db.orderDao().insert(order)
    suspend fun updateOrder(order: Order) = db.orderDao().update(order)
    suspend fun deleteOrder(order: Order) = db.orderDao().delete(order)

    suspend fun getMaterialsList() = db.materialDao().getAllMaterialsList()
    suspend fun insertMaterial(material: Material) = db.materialDao().insert(material)
    suspend fun updateMaterial(material: Material) = db.materialDao().update(material)
    suspend fun deleteMaterial(material: Material) = db.materialDao().delete(material)

    suspend fun insertCustomer(customer: Customer) = db.customerDao().insert(customer)
    suspend fun updateCustomer(customer: Customer) = db.customerDao().update(customer)
    suspend fun deleteCustomer(customer: Customer) = db.customerDao().delete(customer)
}
