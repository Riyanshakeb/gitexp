package com.azizgraphics.clcltr.ui.calculate

import android.text.Editable
import android.text.TextWatcher
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.*
import androidx.recyclerview.widget.RecyclerView
import com.azizgraphics.clcltr.R
import com.azizgraphics.clcltr.data.model.BannerItem
import com.azizgraphics.clcltr.util.CurrencyFormatter

class BannerItemAdapter(
    private val items: MutableList<BannerItem>,
    private val currency: String,
    private val onItemChanged: (Int, BannerItem) -> Unit,
    private val onDeleteItem: (Int) -> Unit
) : RecyclerView.Adapter<BannerItemAdapter.ViewHolder>() {

    class ViewHolder(view: View) : RecyclerView.ViewHolder(view) {
        val tvItemTitle: TextView = view.findViewById(R.id.tv_item_title)
        val etWidth: EditText = view.findViewById(R.id.et_width)
        val spinnerWidthUnit: Spinner = view.findViewById(R.id.spinner_width_unit)
        val etHeight: EditText = view.findViewById(R.id.et_height)
        val spinnerHeightUnit: Spinner = view.findViewById(R.id.spinner_height_unit)
        val etQuantity: EditText = view.findViewById(R.id.et_quantity)
        val etPrice: EditText = view.findViewById(R.id.et_price)
        val tvItemTotal: TextView = view.findViewById(R.id.tv_item_total)
        val tvItemArea: TextView = view.findViewById(R.id.tv_item_area)
        val btnDelete: ImageButton = view.findViewById(R.id.btn_delete_item)
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val view = LayoutInflater.from(parent.context)
            .inflate(R.layout.item_banner, parent, false)
        return ViewHolder(view)
    }

    override fun getItemCount() = items.size

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val item = items[position]
        holder.tvItemTitle.text = "Banner ${position + 1}"

        holder.etWidth.removeTextChangedListener(holder.etWidth.tag as? TextWatcher)
        holder.etHeight.removeTextChangedListener(holder.etHeight.tag as? TextWatcher)
        holder.etQuantity.removeTextChangedListener(holder.etQuantity.tag as? TextWatcher)
        holder.etPrice.removeTextChangedListener(holder.etPrice.tag as? TextWatcher)

        if (item.width > 0) holder.etWidth.setText(item.width.toString())
        else holder.etWidth.setText("")
        if (item.height > 0) holder.etHeight.setText(item.height.toString())
        else holder.etHeight.setText("")
        holder.etQuantity.setText(item.quantity.toString())
        if (item.pricePerSqFt > 0) holder.etPrice.setText(item.pricePerSqFt.toString())
        else holder.etPrice.setText("")

        val units = arrayOf("Feet", "Inches")
        val wAdapter = ArrayAdapter(holder.itemView.context, android.R.layout.simple_spinner_item, units)
        wAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
        holder.spinnerWidthUnit.adapter = wAdapter
        holder.spinnerWidthUnit.setSelection(if (item.widthUnit == "Inches") 1 else 0)

        val hAdapter = ArrayAdapter(holder.itemView.context, android.R.layout.simple_spinner_item, units)
        hAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
        holder.spinnerHeightUnit.adapter = hAdapter
        holder.spinnerHeightUnit.setSelection(if (item.heightUnit == "Inches") 1 else 0)

        updateTotals(holder, item)

        val widthWatcher = createWatcher { text ->
            val pos = holder.adapterPosition
            if (pos != RecyclerView.NO_POSITION) {
                items[pos].width = text.toDoubleOrNull() ?: 0.0
                updateTotals(holder, items[pos])
                onItemChanged(pos, items[pos])
            }
        }
        holder.etWidth.addTextChangedListener(widthWatcher)
        holder.etWidth.tag = widthWatcher

        val heightWatcher = createWatcher { text ->
            val pos = holder.adapterPosition
            if (pos != RecyclerView.NO_POSITION) {
                items[pos].height = text.toDoubleOrNull() ?: 0.0
                updateTotals(holder, items[pos])
                onItemChanged(pos, items[pos])
            }
        }
        holder.etHeight.addTextChangedListener(heightWatcher)
        holder.etHeight.tag = heightWatcher

        val qtyWatcher = createWatcher { text ->
            val pos = holder.adapterPosition
            if (pos != RecyclerView.NO_POSITION) {
                items[pos].quantity = text.toIntOrNull() ?: 1
                updateTotals(holder, items[pos])
                onItemChanged(pos, items[pos])
            }
        }
        holder.etQuantity.addTextChangedListener(qtyWatcher)
        holder.etQuantity.tag = qtyWatcher

        val priceWatcher = createWatcher { text ->
            val pos = holder.adapterPosition
            if (pos != RecyclerView.NO_POSITION) {
                items[pos].pricePerSqFt = text.toDoubleOrNull() ?: 0.0
                updateTotals(holder, items[pos])
                onItemChanged(pos, items[pos])
            }
        }
        holder.etPrice.addTextChangedListener(priceWatcher)
        holder.etPrice.tag = priceWatcher

        holder.spinnerWidthUnit.onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
            override fun onItemSelected(parent: AdapterView<*>?, view: View?, pos2: Int, id: Long) {
                val pos = holder.adapterPosition
                if (pos != RecyclerView.NO_POSITION) {
                    items[pos].widthUnit = units[pos2]
                    updateTotals(holder, items[pos])
                    onItemChanged(pos, items[pos])
                }
            }
            override fun onNothingSelected(parent: AdapterView<*>?) {}
        }

        holder.spinnerHeightUnit.onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
            override fun onItemSelected(parent: AdapterView<*>?, view: View?, pos2: Int, id: Long) {
                val pos = holder.adapterPosition
                if (pos != RecyclerView.NO_POSITION) {
                    items[pos].heightUnit = units[pos2]
                    updateTotals(holder, items[pos])
                    onItemChanged(pos, items[pos])
                }
            }
            override fun onNothingSelected(parent: AdapterView<*>?) {}
        }

        holder.btnDelete.setOnClickListener {
            val pos = holder.adapterPosition
            if (pos != RecyclerView.NO_POSITION) onDeleteItem(pos)
        }
    }

    private fun updateTotals(holder: ViewHolder, item: BannerItem) {
        holder.tvItemArea.text = String.format("%.2f sq.ft", item.totalArea)
        holder.tvItemTotal.text = CurrencyFormatter.format(item.totalPrice, currency)
    }

    private fun createWatcher(onChange: (String) -> Unit): TextWatcher {
        return object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {}
            override fun afterTextChanged(s: Editable?) {
                onChange(s?.toString() ?: "")
            }
        }
    }
}
