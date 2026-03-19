package com.azizgraphics.clcltr.ui.calculate

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.viewModelScope
import com.azizgraphics.clcltr.BannerCalculatorApp
import com.azizgraphics.clcltr.data.model.BannerItem
import com.azizgraphics.clcltr.data.model.Order
import com.google.gson.Gson
import kotlinx.coroutines.launch

class CalculateViewModel(application: Application) : AndroidViewModel(application) {
    private val app = application as BannerCalculatorApp
    private val repository = app.repository
    private val gson = Gson()

    private val _items = MutableLiveData<MutableList<BannerItem>>(mutableListOf(BannerItem()))
    val items: LiveData<MutableList<BannerItem>> = _items

    private val _totalPrice = MutableLiveData(0.0)
    val totalPrice: LiveData<Double> = _totalPrice

    private val _totalSqft = MutableLiveData(0.0)
    val totalSqft: LiveData<Double> = _totalSqft

    fun addItem() {
        val list = _items.value ?: mutableListOf()
        val newItem = BannerItem(
            pricePerSqFt = app.prefsManager.defaultPrice,
            widthUnit = app.prefsManager.defaultUnit,
            heightUnit = app.prefsManager.defaultUnit
        )
        list.add(newItem)
        _items.value = list
        recalculate()
    }

    fun removeItem(position: Int) {
        val list = _items.value ?: return
        if (position in list.indices) {
            list.removeAt(position)
            _items.value = list
            recalculate()
        }
    }

    fun updateItem(position: Int, item: BannerItem) {
        val list = _items.value ?: return
        if (position in list.indices) {
            list[position] = item
            _items.value = list
            recalculate()
        }
    }

    fun clearAll() {
        _items.value = mutableListOf(BannerItem())
        recalculate()
    }

    fun recalculate() {
        val list = _items.value ?: return
        _totalPrice.value = list.sumOf { it.totalPrice }
        _totalSqft.value = list.sumOf { it.totalArea }
    }

    fun saveOrder(projectName: String) {
        val list = _items.value ?: return
        val order = Order(
            projectName = projectName,
            itemsJson = gson.toJson(list),
            totalAmount = list.sumOf { it.totalPrice },
            totalQuantity = list.sumOf { it.quantity },
            totalSqft = list.sumOf { it.totalArea },
            currency = app.prefsManager.currency
        )
        viewModelScope.launch {
            repository.insertOrder(order)
        }
    }

    fun getMaterials() = repository.allMaterials
}
