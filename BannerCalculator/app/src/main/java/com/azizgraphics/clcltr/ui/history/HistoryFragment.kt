package com.azizgraphics.clcltr.ui.history

import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.lifecycle.ViewModelProvider
import androidx.recyclerview.widget.LinearLayoutManager
import com.azizgraphics.clcltr.BannerCalculatorApp
import com.azizgraphics.clcltr.data.model.BannerItem
import com.azizgraphics.clcltr.data.model.Order
import com.azizgraphics.clcltr.databinding.FragmentHistoryBinding
import com.azizgraphics.clcltr.util.CurrencyFormatter
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken

class HistoryFragment : Fragment() {

    private var _binding: FragmentHistoryBinding? = null
    private val binding get() = _binding!!
    private lateinit var viewModel: HistoryViewModel

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        _binding = FragmentHistoryBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        viewModel = ViewModelProvider(this)[HistoryViewModel::class.java]

        binding.rvOrders.layoutManager = LinearLayoutManager(requireContext())

        viewModel.orders.observe(viewLifecycleOwner) { orders ->
            if (orders.isEmpty()) {
                binding.emptyState.visibility = View.VISIBLE
                binding.rvOrders.visibility = View.GONE
            } else {
                binding.emptyState.visibility = View.GONE
                binding.rvOrders.visibility = View.VISIBLE
                binding.rvOrders.adapter = OrderAdapter(orders,
                    onShare = { order -> shareOrder(order) },
                    onDelete = { order -> viewModel.deleteOrder(order) }
                )
            }
        }
    }

    private fun shareOrder(order: Order) {
        val gson = Gson()
        val type = object : TypeToken<List<BannerItem>>() {}.type
        val items: List<BannerItem> = gson.fromJson(order.itemsJson, type)

        val sb = StringBuilder()
        sb.appendLine("═══ ${order.projectName} ═══")
        sb.appendLine("Date: ${java.text.SimpleDateFormat("dd MMM yyyy, hh:mm a", java.util.Locale.US).format(java.util.Date(order.createdAt))}")
        sb.appendLine("───────────────")
        items.forEachIndexed { i, item ->
            sb.appendLine("Banner ${i + 1}: ${item.dimensionDisplay()}")
            sb.appendLine("  Qty: ${item.quantity} | Area: ${"%.2f".format(item.totalArea)} sq.ft")
            sb.appendLine("  Price: ${CurrencyFormatter.format(item.totalPrice, order.currency)}")
        }
        sb.appendLine("───────────────")
        sb.appendLine("Total: ${CurrencyFormatter.format(order.totalAmount, order.currency)}")
        sb.appendLine("Total Area: ${"%.2f".format(order.totalSqft)} sq.ft")

        val intent = Intent(Intent.ACTION_SEND).apply {
            type = "text/plain"
            putExtra(Intent.EXTRA_TEXT, sb.toString())
        }
        startActivity(Intent.createChooser(intent, "Share Order"))
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
