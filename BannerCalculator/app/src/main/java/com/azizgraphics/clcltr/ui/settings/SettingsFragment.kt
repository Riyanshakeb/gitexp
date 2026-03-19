package com.azizgraphics.clcltr.ui.settings

import android.app.AlertDialog
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ArrayAdapter
import android.widget.EditText
import android.widget.LinearLayout
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.lifecycle.ViewModelProvider
import com.azizgraphics.clcltr.BannerCalculatorApp
import com.azizgraphics.clcltr.data.model.Customer
import com.azizgraphics.clcltr.data.model.Material
import com.azizgraphics.clcltr.databinding.FragmentSettingsBinding
import com.azizgraphics.clcltr.util.CurrencyFormatter

class SettingsFragment : Fragment() {

    private var _binding: FragmentSettingsBinding? = null
    private val binding get() = _binding!!
    private lateinit var viewModel: SettingsViewModel
    private lateinit var app: BannerCalculatorApp

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        _binding = FragmentSettingsBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        app = requireActivity().application as BannerCalculatorApp
        viewModel = ViewModelProvider(this)[SettingsViewModel::class.java]

        setupDefaults()
        setupAppearance()
        setupManagement()
        setupAbout()
    }

    private fun setupDefaults() {
        binding.tvCurrentUnit.text = app.prefsManager.defaultUnit
        binding.cardDefaultUnit.setOnClickListener {
            val units = arrayOf("Feet", "Inches")
            AlertDialog.Builder(requireContext())
                .setTitle("Default Unit")
                .setItems(units) { _, which ->
                    app.prefsManager.defaultUnit = units[which]
                    binding.tvCurrentUnit.text = units[which]
                }
                .show()
        }

        binding.tvCurrentPrice.text = app.prefsManager.defaultPrice.let {
            if (it > 0) it.toString() else "Not set"
        }
        binding.cardDefaultPrice.setOnClickListener {
            val input = EditText(requireContext())
            input.hint = "Price per sq.ft"
            input.inputType = android.text.InputType.TYPE_CLASS_NUMBER or android.text.InputType.TYPE_NUMBER_FLAG_DECIMAL
            input.setPadding(48, 32, 48, 32)
            AlertDialog.Builder(requireContext())
                .setTitle("Default Price per Sq.Ft")
                .setView(input)
                .setPositiveButton("Save") { _, _ ->
                    val price = input.text.toString().toDoubleOrNull() ?: 0.0
                    app.prefsManager.defaultPrice = price
                    binding.tvCurrentPrice.text = if (price > 0) price.toString() else "Not set"
                }
                .setNegativeButton("Cancel", null)
                .show()
        }
    }

    private fun setupAppearance() {
        binding.tvCurrentTheme.text = app.prefsManager.themeMode
        binding.cardTheme.setOnClickListener {
            val themes = arrayOf("System", "Light", "Dark")
            AlertDialog.Builder(requireContext())
                .setTitle("Theme")
                .setItems(themes) { _, which ->
                    app.prefsManager.themeMode = themes[which]
                    binding.tvCurrentTheme.text = themes[which]
                    app.applyTheme(themes[which])
                }
                .show()
        }

        binding.tvCurrentCurrency.text = app.prefsManager.currency
        binding.cardCurrency.setOnClickListener {
            val currencies = CurrencyFormatter.getSupportedCurrencies().toTypedArray()
            AlertDialog.Builder(requireContext())
                .setTitle("Currency")
                .setItems(currencies) { _, which ->
                    app.prefsManager.currency = currencies[which]
                    binding.tvCurrentCurrency.text = currencies[which]
                }
                .show()
        }
    }

    private fun setupManagement() {
        binding.cardMaterials.setOnClickListener {
            showMaterialsDialog()
        }
        binding.cardCustomers.setOnClickListener {
            showCustomersDialog()
        }
    }

    private fun showMaterialsDialog() {
        viewModel.materials.observe(viewLifecycleOwner) { materials ->
            val names = materials.map { it.name }.toMutableList()
            names.add("+ Add New Material")

            AlertDialog.Builder(requireContext())
                .setTitle("Materials")
                .setItems(names.toTypedArray()) { _, which ->
                    if (which == names.size - 1) {
                        showAddMaterialDialog()
                    } else {
                        showEditMaterialDialog(materials[which])
                    }
                }
                .setNegativeButton("Close", null)
                .show()
        }
    }

    private fun showAddMaterialDialog() {
        val input = EditText(requireContext())
        input.hint = "Material name"
        input.setPadding(48, 32, 48, 32)
        AlertDialog.Builder(requireContext())
            .setTitle("Add Material")
            .setView(input)
            .setPositiveButton("Add") { _, _ ->
                val name = input.text.toString().trim()
                if (name.isNotEmpty()) {
                    viewModel.addMaterial(name)
                    Toast.makeText(requireContext(), "Material added", Toast.LENGTH_SHORT).show()
                }
            }
            .setNegativeButton("Cancel", null)
            .show()
    }

    private fun showEditMaterialDialog(material: Material) {
        AlertDialog.Builder(requireContext())
            .setTitle(material.name)
            .setItems(arrayOf("Edit", "Delete")) { _, which ->
                when (which) {
                    0 -> {
                        val input = EditText(requireContext())
                        input.setText(material.name)
                        input.setPadding(48, 32, 48, 32)
                        AlertDialog.Builder(requireContext())
                            .setTitle("Edit Material")
                            .setView(input)
                            .setPositiveButton("Save") { _, _ ->
                                viewModel.updateMaterial(material.copy(name = input.text.toString().trim()))
                            }
                            .setNegativeButton("Cancel", null)
                            .show()
                    }
                    1 -> viewModel.deleteMaterial(material)
                }
            }
            .show()
    }

    private fun showCustomersDialog() {
        viewModel.customers.observe(viewLifecycleOwner) { customers ->
            val names = customers.map { "${it.name} (${it.phone})" }.toMutableList()
            names.add("+ Add New Customer")

            AlertDialog.Builder(requireContext())
                .setTitle("Customers")
                .setItems(names.toTypedArray()) { _, which ->
                    if (which == names.size - 1) {
                        showAddCustomerDialog()
                    } else {
                        showEditCustomerDialog(customers[which])
                    }
                }
                .setNegativeButton("Close", null)
                .show()
        }
    }

    private fun showAddCustomerDialog() {
        val layout = LinearLayout(requireContext()).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(48, 32, 48, 16)
        }
        val nameInput = EditText(requireContext()).apply { hint = "Name" }
        val phoneInput = EditText(requireContext()).apply {
            hint = "Phone"
            inputType = android.text.InputType.TYPE_CLASS_PHONE
        }
        layout.addView(nameInput)
        layout.addView(phoneInput)

        AlertDialog.Builder(requireContext())
            .setTitle("Add Customer")
            .setView(layout)
            .setPositiveButton("Add") { _, _ ->
                val name = nameInput.text.toString().trim()
                val phone = phoneInput.text.toString().trim()
                if (name.isNotEmpty()) {
                    viewModel.addCustomer(name, phone)
                    Toast.makeText(requireContext(), "Customer added", Toast.LENGTH_SHORT).show()
                }
            }
            .setNegativeButton("Cancel", null)
            .show()
    }

    private fun showEditCustomerDialog(customer: Customer) {
        AlertDialog.Builder(requireContext())
            .setTitle(customer.name)
            .setItems(arrayOf("Edit", "Delete")) { _, which ->
                when (which) {
                    0 -> {
                        val layout = LinearLayout(requireContext()).apply {
                            orientation = LinearLayout.VERTICAL
                            setPadding(48, 32, 48, 16)
                        }
                        val nameInput = EditText(requireContext()).apply { setText(customer.name) }
                        val phoneInput = EditText(requireContext()).apply { setText(customer.phone) }
                        layout.addView(nameInput)
                        layout.addView(phoneInput)
                        AlertDialog.Builder(requireContext())
                            .setTitle("Edit Customer")
                            .setView(layout)
                            .setPositiveButton("Save") { _, _ ->
                                viewModel.updateCustomer(
                                    customer.copy(
                                        name = nameInput.text.toString().trim(),
                                        phone = phoneInput.text.toString().trim()
                                    )
                                )
                            }
                            .setNegativeButton("Cancel", null)
                            .show()
                    }
                    1 -> viewModel.deleteCustomer(customer)
                }
            }
            .show()
    }

    private fun setupAbout() {
        binding.tvAboutName.text = "\uD835\uDEB0\uD835\uDEC9\uD835\uDEA8\uD835\uDEC9-\uD835\uDEA6\uD835\uDEB1\uD835\uDEB0\uD835\uDEAF\uD835\uDEB7\uD835\uDEA8\uD835\uDEB2\uD835\uDEB4"
        binding.tvAboutPhone.text = "0305-3345518"
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
