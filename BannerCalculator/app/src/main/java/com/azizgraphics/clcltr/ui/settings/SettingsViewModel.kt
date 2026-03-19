package com.azizgraphics.clcltr.ui.settings

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.azizgraphics.clcltr.BannerCalculatorApp
import com.azizgraphics.clcltr.data.model.Customer
import com.azizgraphics.clcltr.data.model.Material
import kotlinx.coroutines.launch

class SettingsViewModel(application: Application) : AndroidViewModel(application) {
    private val repository = (application as BannerCalculatorApp).repository

    val materials = repository.allMaterials
    val customers = repository.allCustomers

    fun addMaterial(name: String) = viewModelScope.launch {
        repository.insertMaterial(Material(name = name))
    }

    fun updateMaterial(material: Material) = viewModelScope.launch {
        repository.updateMaterial(material)
    }

    fun deleteMaterial(material: Material) = viewModelScope.launch {
        repository.deleteMaterial(material)
    }

    fun addCustomer(name: String, phone: String) = viewModelScope.launch {
        repository.insertCustomer(Customer(name = name, phone = phone))
    }

    fun updateCustomer(customer: Customer) = viewModelScope.launch {
        repository.updateCustomer(customer)
    }

    fun deleteCustomer(customer: Customer) = viewModelScope.launch {
        repository.deleteCustomer(customer)
    }
}
