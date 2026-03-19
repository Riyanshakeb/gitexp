package com.azizgraphics.clcltr.ui.calculate

import android.content.Context
import android.graphics.*
import android.util.AttributeSet
import android.view.View
import com.azizgraphics.clcltr.data.model.BannerItem

class BannerPreviewView @JvmOverloads constructor(
    context: Context, attrs: AttributeSet? = null, defStyleAttr: Int = 0
) : View(context, attrs, defStyleAttr) {

    private var items: List<BannerItem> = emptyList()
    private val bannerPaint = Paint(Paint.ANTI_ALIAS_FLAG)
    private val textPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        textSize = 28f
        textAlign = Paint.Align.CENTER
        typeface = Typeface.DEFAULT_BOLD
    }
    private val gridPaint = Paint().apply {
        color = Color.LTGRAY
        strokeWidth = 1f
        pathEffect = DashPathEffect(floatArrayOf(8f, 8f), 0f)
    }
    private val borderPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        style = Paint.Style.STROKE
        strokeWidth = 2f
    }

    private val colors = intArrayOf(
        0xFF4A90D9.toInt(), 0xFF50C878.toInt(), 0xFFFF6B6B.toInt(),
        0xFFFFB347.toInt(), 0xFF9B59B6.toInt(), 0xFF1ABC9C.toInt()
    )

    fun setItems(newItems: List<BannerItem>) {
        items = newItems.filter { it.widthInFeet > 0 && it.heightInFeet > 0 }
        invalidate()
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        val w = width.toFloat()
        val h = height.toFloat()
        val padding = 24f

        drawGrid(canvas, w, h)

        if (items.isEmpty()) return

        val maxW = items.maxOf { it.widthInFeet }
        val maxH = items.maxOf { it.heightInFeet }
        if (maxW == 0.0 || maxH == 0.0) return

        val availW = w - padding * 2
        val availH = h - padding * 2
        val scale = minOf(availW / maxW.toFloat(), availH / (maxH * items.size).toFloat()) * 0.8f

        var yOffset = padding + 16f
        items.forEachIndexed { index, item ->
            val bw = (item.widthInFeet * scale).toFloat()
            val bh = (item.heightInFeet * scale).toFloat()
            val x = padding + (availW - bw) / 2

            val colorIdx = index % colors.size
            bannerPaint.color = colors[colorIdx]
            bannerPaint.alpha = 180

            val rect = RectF(x, yOffset, x + bw, yOffset + bh)
            canvas.drawRoundRect(rect, 8f, 8f, bannerPaint)

            borderPaint.color = colors[colorIdx]
            borderPaint.alpha = 255
            canvas.drawRoundRect(rect, 8f, 8f, borderPaint)

            val isDark = isColorDark(colors[colorIdx])
            textPaint.color = if (isDark) Color.WHITE else Color.BLACK
            textPaint.textSize = minOf(28f, bh * 0.3f, bw * 0.08f).coerceAtLeast(12f)
            canvas.drawText(
                item.dimensionDisplay(),
                rect.centerX(), rect.centerY() + textPaint.textSize / 3,
                textPaint
            )

            yOffset += bh + 12f
        }
    }

    private fun drawGrid(canvas: Canvas, w: Float, h: Float) {
        val step = 40f
        var x = 0f
        while (x <= w) {
            canvas.drawLine(x, 0f, x, h, gridPaint)
            x += step
        }
        var y = 0f
        while (y <= h) {
            canvas.drawLine(0f, y, w, y, gridPaint)
            y += step
        }
    }

    private fun isColorDark(color: Int): Boolean {
        val r = Color.red(color)
        val g = Color.green(color)
        val b = Color.blue(color)
        return (r * 0.299 + g * 0.587 + b * 0.114) < 150
    }
}
