package com.azizgraphics.clcltr.ui.calculate

import android.app.AlertDialog
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.EditText
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.lifecycle.ViewModelProvider
import androidx.recyclerview.widget.LinearLayoutManager
import com.azizgraphics.clcltr.BannerCalculatorApp
import com.azizgraphics.clcltr.R
import com.azizgraphics.clcltr.databinding.FragmentCalculateBinding
import com.azizgraphics.clcltr.util.CurrencyFormatter

class CalculateFragment : Fragment() {

    private var _binding: FragmentCalculateBinding? = null
    private val binding get() = _binding!!
    private lateinit var viewModel: CalculateViewModel
    private var adapter: BannerItemAdapter? = null

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        _binding = FragmentCalculateBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        viewModel = ViewModelProvider(this)[CalculateViewModel::class.java]
        val app = requireActivity().application as BannerCalculatorApp
        val currency = app.prefsManager.currency

        binding.rvItems.layoutManager = LinearLayoutManager(requireContext())

        viewModel.items.observe(viewLifecycleOwner) { items ->
            adapter = BannerItemAdapter(
                items, currency,
                onItemChanged = { pos, item ->
                    viewModel.updateItem(pos, item)
                },
                onDeleteItem = { pos ->
                    viewModel.removeItem(pos)
                    adapter?.notifyDataSetChanged()
                }
            )
            binding.rvItems.adapter = adapter
            binding.bannerPreview.setItems(items)
        }

        viewModel.totalPrice.observe(viewLifecycleOwner) { total ->
            binding.tvTotalAmount.text = CurrencyFormatter.format(total, currency)
        }

        viewModel.totalSqft.observe(viewLifecycleOwner) { sqft ->
            binding.tvTotalSqft.text = String.format("%.2f sq.ft", sqft)
        }

        binding.btnAddItem.setOnClickListener {
            viewModel.addItem()
            adapter?.notifyDataSetChanged()
        }

        binding.btnClearAll.setOnClickListener {
            viewModel.clearAll()
            adapter?.notifyDataSetChanged()
        }

        binding.btnSaveOrder.setOnClickListener {
            showSaveDialog(currency)
        }
    }

    private fun showSaveDialog(currency: String) {
        val input = EditText(requireContext())
        input.hint = "Project name"
        input.setPadding(48, 32, 48, 32)

        AlertDialog.Builder(requireContext())
            .setTitle("Save Order")
            .setView(input)
            .setPositiveButton("Save") { _, _ ->
                val name = input.text.toString().ifBlank { "Untitled Project" }
                viewModel.saveOrder(name)
                Toast.makeText(requireContext(), "Order saved!", Toast.LENGTH_SHORT).show()
            }
            .setNegativeButton("Cancel", null)
            .show()
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
