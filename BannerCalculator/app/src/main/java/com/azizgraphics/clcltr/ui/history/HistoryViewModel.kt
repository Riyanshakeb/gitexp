package com.azizgraphics.clcltr.ui.history

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.azizgraphics.clcltr.BannerCalculatorApp
import com.azizgraphics.clcltr.data.model.Order
import kotlinx.coroutines.launch

class HistoryViewModel(application: Application) : AndroidViewModel(application) {
    private val repository = (application as BannerCalculatorApp).repository
    val orders = repository.allOrders

    fun deleteOrder(order: Order) {
        viewModelScope.launch {
            repository.deleteOrder(order)
        }
    }
}
