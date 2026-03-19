package com.azizgraphics.clcltr.ui.history

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageButton
import android.widget.LinearLayout
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.azizgraphics.clcltr.R
import com.azizgraphics.clcltr.data.model.BannerItem
import com.azizgraphics.clcltr.data.model.Order
import com.azizgraphics.clcltr.util.CurrencyFormatter
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import java.text.SimpleDateFormat
import java.util.*

class OrderAdapter(
    private val orders: List<Order>,
    private val onShare: (Order) -> Unit,
    private val onDelete: (Order) -> Unit
) : RecyclerView.Adapter<OrderAdapter.ViewHolder>() {

    private val gson = Gson()
    private val dateFormat = SimpleDateFormat("dd MMM yyyy, hh:mm a", Locale.US)

    class ViewHolder(view: View) : RecyclerView.ViewHolder(view) {
        val tvProjectName: TextView = view.findViewById(R.id.tv_project_name)
        val tvDate: TextView = view.findViewById(R.id.tv_date)
        val tvTotal: TextView = view.findViewById(R.id.tv_order_total)
        val tvQuantity: TextView = view.findViewById(R.id.tv_order_qty)
        val detailsContainer: LinearLayout = view.findViewById(R.id.details_container)
        val btnShare: ImageButton = view.findViewById(R.id.btn_share)
        val btnDelete: ImageButton = view.findViewById(R.id.btn_delete_order)
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val view = LayoutInflater.from(parent.context)
            .inflate(R.layout.item_order, parent, false)
        return ViewHolder(view)
    }

    override fun getItemCount() = orders.size

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val order = orders[position]
        holder.tvProjectName.text = order.projectName
        holder.tvDate.text = dateFormat.format(Date(order.createdAt))
        holder.tvTotal.text = CurrencyFormatter.format(order.totalAmount, order.currency)
        holder.tvQuantity.text = "Qty: ${order.totalQuantity}"

        holder.detailsContainer.visibility = View.GONE
        holder.itemView.setOnClickListener {
            val isVisible = holder.detailsContainer.visibility == View.VISIBLE
            holder.detailsContainer.visibility = if (isVisible) View.GONE else View.VISIBLE
            if (!isVisible) {
                populateDetails(holder, order)
            }
        }

        holder.btnShare.setOnClickListener { onShare(order) }
        holder.btnDelete.setOnClickListener { onDelete(order) }
    }

    private fun populateDetails(holder: ViewHolder, order: Order) {
        holder.detailsContainer.removeAllViews()
        val type = object : TypeToken<List<BannerItem>>() {}.type
        val items: List<BannerItem> = try {
            gson.fromJson(order.itemsJson, type)
        } catch (e: Exception) {
            emptyList()
        }
        items.forEachIndexed { i, item ->
            val tv = TextView(holder.itemView.context).apply {
                text = "Banner ${i + 1}: ${item.dimensionDisplay()} | Qty: ${item.quantity} | ${CurrencyFormatter.format(item.totalPrice, order.currency)}"
                setPadding(0, 8, 0, 8)
                textSize = 13f
            }
            holder.detailsContainer.addView(tv)
        }
    }
}
