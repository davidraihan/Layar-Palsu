Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

[System.Windows.Forms.Application]::EnableVisualStyles()

# ===== COLORS =====
 $red    = [System.Drawing.Color]::FromArgb(130, 0, 0)
 $dark   = [System.Drawing.Color]::FromArgb(85, 0, 0)
 $panel  = [System.Drawing.Color]::FromArgb(155, 12, 12)
 $white  = [System.Drawing.Color]::White
 $yellow = [System.Drawing.Color]::Yellow
 $paper  = [System.Drawing.Color]::FromArgb(245, 235, 220)   # krem seperti layar asli
 $ink    = [System.Drawing.Color]::FromArgb(45, 45, 45)
 $head   = [System.Drawing.Color]::FromArgb(150, 0, 0)

# teks LED (awal sama seperti sebelumnya)
 $script:countdownText = "02:23:57"

# ===== HELPERS =====
function Enable-DoubleBuffer([System.Windows.Forms.Control]$c) {
    try {
        $flags = [System.Reflection.BindingFlags]'Instance,NonPublic,Public'
        $p = $c.GetType().GetProperty('DoubleBuffered', $flags)
        if ($p) { $p.SetValue($c, $true, $null) }
    } catch { }
}

# Render angka gaya tujuh-segmen (LED seperti countdown aslinya)
function Draw-SevenSegment {
    param(
        [System.Drawing.Graphics]$g,
        [string]$Text,
        [System.Drawing.Rectangle]$Bounds,
        [System.Drawing.Color]$ColorOn,
        [System.Drawing.Color]$ColorOff,
        [double]$DigitW = 34,
        [double]$DigitH = 62,
        [double]$Thickness = 9,
        [double]$Gap = 10,
        [double]$ColonW = 16
    )
    if ([string]::IsNullOrEmpty($Text)) { return }

    $map = @{
        '0' = 'ABCDEF';  '1' = 'BC';      '2' = 'ABDEG';   '3' = 'ABCDG'
        '4' = 'BCFG';    '5' = 'ACDFG';   '6' = 'ACDEFG'
        '7' = 'ABC';     '8' = 'ABCDEFG'; '9' = 'ABCDFG'
    }

    $units = 0
    foreach ($ch in $Text.ToCharArray()) {
        if ($ch -eq ':') { $units += $ColonW } else { $units += $DigitW }
    }
    $gapCount = $Text.Length - 1
    $units += $Gap * $gapCount
    if ($units -le 0) { return }

    $availW = $Bounds.Width
    $availH = $Bounds.Height - 10
    if ($availW -lt 20 -or $availH -lt 10) { return }
    $scale = [Math]::Min($availW / $units, $availH / $DigitH)

    $dw = $DigitW * $scale
    $dh = $DigitH * $scale
    $th = [Math]::Max(3.0, $Thickness * $scale)
    $gp = $Gap * $scale
    $cw = $ColonW * $scale
    $total = $units * $scale

    $x = $Bounds.X + ($availW - $total) / 2.0
    $y = $Bounds.Y + ($Bounds.Height - $dh) / 2.0

    $penOff = New-Object System.Drawing.Pen($ColorOff, $th)
    $penOn  = New-Object System.Drawing.Pen($ColorOn, $th)
    $cap = [System.Drawing.Drawing2D.LineCap]::Round
    $penOff.StartCap = $cap; $penOff.EndCap = $cap
    $penOn.StartCap = $cap;  $penOn.EndCap = $cap
    $brushOn = New-Object System.Drawing.SolidBrush($ColorOn)

    foreach ($ch in $Text.ToCharArray()) {
        if ($ch -eq ':') {
            $ccx = $x + $cw / 2.0
            $d1 = $y + $dh * 0.30
            $d2 = $y + $dh * 0.70
            foreach ($fy in @($d1, $d2)) {
                $ex0 = [float]($ccx - $th * 0.55)
                $ey0 = [float]($fy - $th * 0.55)
                $es0 = [float]($th * 1.1)
                $g.FillEllipse($brushOn, $ex0, $ey0, $es0, $es0)
            }
            $x += $cw + $gp
            continue
        }

        $segs = $map[[string]$ch]
        if (-not $segs) { $x += $dw + $gp; continue }

        $i   = [Math]::Max(2.0, $th * 0.85)
        $ax  = $x + $i
        $bx  = $x + $dw - $i
        $ex  = $x + $dw
        $ey  = $y + $dh
        $my  = $y + $dh / 2.0
        $ty  = $y + $i
        $byy = $ey - $i

        $pA1 = New-Object System.Drawing.PointF($ax, $y)
        $pA2 = New-Object System.Drawing.PointF($bx, $y)
        $pB1 = New-Object System.Drawing.PointF($ex, $ty)
        $pB2 = New-Object System.Drawing.PointF($ex, $my)
        $pC1 = New-Object System.Drawing.PointF($ex, $my)
        $pC2 = New-Object System.Drawing.PointF($ex, $byy)
        $pD1 = New-Object System.Drawing.PointF($ax, $ey)
        $pD2 = New-Object System.Drawing.PointF($bx, $ey)
        $pE1 = New-Object System.Drawing.PointF($x, $my)
        $pE2 = New-Object System.Drawing.PointF($x, $byy)
        $pF1 = New-Object System.Drawing.PointF($x, $ty)
        $pF2 = New-Object System.Drawing.PointF($x, $my)
        $pG1 = New-Object System.Drawing.PointF($ax, $my)
        $pG2 = New-Object System.Drawing.PointF($bx, $my)

        $P = @{
            'A' = @($pA1, $pA2); 'B' = @($pB1, $pB2); 'C' = @($pC1, $pC2)
            'D' = @($pD1, $pD2); 'E' = @($pE1, $pE2); 'F' = @($pF1, $pF2)
            'G' = @($pG1, $pG2)
        }

        foreach ($s in @('A','B','C','D','E','F','G')) {
            $pair = $P[$s]
            $g.DrawLine($penOff, $pair[0], $pair[1])
        }
        foreach ($s in $segs.ToCharArray()) {
            $pair = $P[[string]$s]
            $g.DrawLine($penOn, $pair[0], $pair[1])
        }
        $x += $dw + $gp
    }
    $penOff.Dispose(); $penOn.Dispose(); $brushOn.Dispose()
}

# ===== MAIN FORM =====
 $form = New-Object System.Windows.Forms.Form
 $form.Text = "WanaDecrypt0r 2.0 - SIMULATION"
 $form.WindowState = "Maximized"
 $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None
 $form.BackColor = $red
 $form.ForeColor = $white
 $form.Font = New-Object System.Drawing.Font("Arial", 10)
 $form.MinimumSize = New-Object System.Drawing.Size(850, 600)
 $form.KeyPreview = $true
 $form.TopMost = $true
 $form.StartPosition = "CenterScreen"
Enable-DoubleBuffer $form

# Menangani input keyboard (Hanya ESC yang diizinkan untuk keluar, tombol lain diabaikan)
 $form.Add_KeyDown({
    if ($_.KeyCode -eq "Escape") {
        $form.Close()
    } else {
        $_.Handled = $true
    }
})

# Memastikan form tetap fokus dan di depan jika pengguna mencoba berpindah
 $form.Add_Activated({
    $form.TopMost = $true
})

# ===== HEADER =====
 $header = New-Object System.Windows.Forms.Panel
 $header.Dock = "Top"
 $header.Height = 75
 $header.BackColor = $dark
 $form.Controls.Add($header)

 $title = New-Object System.Windows.Forms.Label
 $title.Text = "Wana Decrypt0r 2.0"
 $title.Font = New-Object System.Drawing.Font("Arial", 24, [System.Drawing.FontStyle]::Bold)
 $title.ForeColor = $white
 $title.Location = New-Object System.Drawing.Point(25, 10)
 $title.AutoSize = $true
 $header.Controls.Add($title)

 $demo = New-Object System.Windows.Forms.Label
 $demo.Text = "SIMULATION / SECURITY AWARENESS DEMO"
 $demo.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
 $demo.ForeColor = $yellow
 $demo.Location = New-Object System.Drawing.Point(30, 49)
 $demo.AutoSize = $true
 $header.Controls.Add($demo)

# garis aksen kuning tipis di bawah header (hanya tampilan)
 $header.Add_Paint({
    param($sender, $e)
    $pen = New-Object System.Drawing.Pen($yellow, 2)
    $e.Graphics.DrawLine($pen, 0, ($sender.Height - 1), $sender.Width, ($sender.Height - 1))
    $pen.Dispose()
})
Enable-DoubleBuffer $header

# ===== MAIN CONTENT =====
 $main = New-Object System.Windows.Forms.TableLayoutPanel
 $main.Dock = "Fill"
 $main.Padding = New-Object System.Windows.Forms.Padding(18)
 $main.ColumnCount = 2
 $main.RowCount = 1
 $colStyle1 = New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 35)
 $colStyle2 = New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 65)
[void]$main.ColumnStyles.Add($colStyle1)
[void]$main.ColumnStyles.Add($colStyle2)
 $form.Controls.Add($main)
 $main.BringToFront()

# ===== LEFT PANEL =====
 $left = New-Object System.Windows.Forms.Panel
 $left.Dock = "Fill"
 $left.BackColor = $dark
 $main.Controls.Add($left, 0, 0)
Enable-DoubleBuffer $left

# --- Ikon gembok digambar langsung (padlock putih seperti layar asli) ---
 $lockPanel = New-Object System.Windows.Forms.Panel
 $lockPanel.BackColor = $dark
 $left.Controls.Add($lockPanel)
Enable-DoubleBuffer $lockPanel

 $lockPanel.Add_Paint({
    param($sender, $e)
    $g = $e.Graphics
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $w = $sender.ClientSize.Width
    $h = $sender.ClientSize.Height
    if ($w -lt 20 -or $h -lt 20) { return }

    $sc  = [Math]::Min($w / 170.0, $h / 195.0)
    $cx  = $w / 2.0
    $top = ($h - 195.0 * $sc) / 2.0

    # shackle (lengkung atas gembok)
    $penW = [float][Math]::Max(6.0, 15.0 * $sc)
    $shPen = New-Object System.Drawing.Pen([System.Drawing.Color]::White, $penW)
    $arcX = [float]($cx - 43.0 * $sc)
    $arcY = [float]($top + 6.0 * $sc)
    $arcW = [float](86.0 * $sc)
    $arcH = [float](112.0 * $sc)
    $g.DrawArc($shPen, $arcX, $arcY, $arcW, $arcH, 180, 180)

    # badan gembok (rounded rectangle putih)
    $bw = 132.0 * $sc
    $bh = 120.0 * $sc
    $bx = $cx - $bw / 2.0
    $by = $top + 62.0 * $sc
    $r  = 18.0 * $sc
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddArc([float]$bx,          [float]$by,          [float]$r, [float]$r, 180, 90)
    $path.AddArc([float]($bx+$bw-$r), [float]$by,          [float]$r, [float]$r, 270, 90)
    $path.AddArc([float]($bx+$bw-$r), [float]($by+$bh-$r), [float]$r, [float]$r, 0,   90)
    $path.AddArc([float]$bx,          [float]($by+$bh-$r), [float]$r, [float]$r, 90,  90)
    $path.CloseFigure()
    $g.FillPath([System.Drawing.Brushes]::White, $path)

    # lubang kunci
    $ky = $by + 44.0 * $sc
    $kr = 15.0 * $sc
    $hole = New-Object System.Drawing.SolidBrush($dark)
    $hx = [float]($cx - $kr)
    $hy = [float]($ky - $kr)
    $hd = [float](2 * $kr)
    $g.FillEllipse($hole, $hx, $hy, $hd, $hd)

    $t1x = [float]($cx - 8.5  * $sc); $t1y = [float]($ky + 2  * $sc)
    $t2x = [float]($cx + 8.5  * $sc); $t2y = [float]($ky + 2  * $sc)
    $t3x = [float]($cx + 13.0 * $sc); $t3y = [float]($ky + 56 * $sc)
    $t4x = [float]($cx - 13.0 * $sc); $t4y = [float]($ky + 56 * $sc)
    $tf1 = New-Object System.Drawing.PointF($t1x, $t1y)
    $tf2 = New-Object System.Drawing.PointF($t2x, $t2y)
    $tf3 = New-Object System.Drawing.PointF($t3x, $t3y)
    $tf4 = New-Object System.Drawing.PointF($t4x, $t4y)
    $tail = [System.Drawing.PointF[]]@($tf1, $tf2, $tf3, $tf4)
    $g.FillPolygon($hole, $tail)

    $path.Dispose(); $hole.Dispose(); $shPen.Dispose()
})

# --- Judul kiri ---
 $leftTitle = New-Object System.Windows.Forms.Label
 $leftTitle.Text = "YOUR FILES ARE SAFE"
 $leftTitle.Font = New-Object System.Drawing.Font("Arial", 16, [System.Drawing.FontStyle]::Bold)
 $leftTitle.ForeColor = $yellow
 $leftTitle.TextAlign = "MiddleCenter"
 $leftTitle.AutoSize = $false
 $left.Controls.Add($leftTitle)

# --- Heading countdown ---
 $cdHeading = New-Object System.Windows.Forms.Label
 $cdHeading.Text = "SIMULATED COUNTDOWN"
 $cdHeading.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
 $cdHeading.ForeColor = $yellow
 $cdHeading.TextAlign = "MiddleCenter"
 $cdHeading.AutoSize = $false
 $left.Controls.Add($cdHeading)

# --- Display countdown gaya LED ---
 $ledPanel = New-Object System.Windows.Forms.Panel
 $ledPanel.BackColor = [System.Drawing.Color]::FromArgb(26, 3, 3)
 $left.Controls.Add($ledPanel)
Enable-DoubleBuffer $ledPanel

 $ledPanel.Add_Paint({
    param($sender, $e)
    $g = $e.Graphics
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $w = $sender.ClientSize.Width
    $h = $sender.ClientSize.Height
    $frame = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(150, 45, 10, 10))
    $g.DrawRectangle($frame, 0, 0, ($w - 1), ($h - 1))
    $frame.Dispose()
    $rX = 6; $rY = 4
    $rW = $w - 12
    $rH = $h - 8
    $ledBounds = New-Object System.Drawing.Rectangle($rX, $rY, $rW, $rH)
    $offColor = [System.Drawing.Color]::FromArgb(55, 255, 255, 255)
    Draw-SevenSegment -g $g -Text $script:countdownText -Bounds $ledBounds -ColorOn $white -ColorOff $offColor
})

# --- Kartu status ---
 $statusCard = New-Object System.Windows.Forms.Panel
 $statusCard.BackColor = [System.Drawing.Color]::FromArgb(40, 0, 0)
 $left.Controls.Add($statusCard)

 $cardHead = New-Object System.Windows.Forms.Label
 $cardHead.Text = "SIMULATION STATUS"
 $cardHead.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
 $cardHead.ForeColor = $yellow
 $cardHead.Dock = "Top"
 $cardHead.Height = 30
 $cardHead.TextAlign = "MiddleLeft"
 $cardHead.Padding = New-Object System.Windows.Forms.Padding(12, 6, 0, 0)
 $statusCard.Controls.Add($cardHead)

 $cardVal = New-Object System.Windows.Forms.Label
 $cardVal.Text = "DEMO MODE"
 $cardVal.Font = New-Object System.Drawing.Font("Consolas", 20, [System.Drawing.FontStyle]::Bold)
 $cardVal.ForeColor = $white
 $cardVal.Dock = "Fill"
 $cardVal.TextAlign = "MiddleLeft"
 $cardVal.Padding = New-Object System.Windows.Forms.Padding(12, 0, 0, 0)
 $statusCard.Controls.Add($cardVal)

 $statusCard.Add_Paint({
    param($sender, $e)
    $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(160, 110, 25, 25))
    $e.Graphics.DrawRectangle($pen, 0, 0, ($sender.ClientSize.Width - 1), ($sender.ClientSize.Height - 1))
    $pen.Dispose()
})

 $leftNote = New-Object System.Windows.Forms.Label
 $leftNote.Text = "This screen does not encrypt files.`nNo payment is required."
 $leftNote.ForeColor = $yellow
 $leftNote.Font = New-Object System.Drawing.Font("Arial", 10)
 $leftNote.AutoSize = $true
 $left.Controls.Add($leftNote)

# --- Penataan kolom kiri (dipusatkan otomatis saat resize) ---
function Update-LeftLayout {
    $w = $left.ClientSize.Width
    $h = $left.ClientSize.Height
    if ($w -lt 60 -or $h -lt 60) { return }

    $lockH = [Math]::Min(200, [Math]::Max(112, [int]($h * 0.24)))
    $lockW = 180
    $lockX = [int](($w - $lockW) / 2)
    $lockPanel.Size = New-Object System.Drawing.Size($lockW, $lockH)
    $lockPanel.Location = New-Object System.Drawing.Point($lockX, 8)

    $y = 8 + $lockH + 4

    $innerW = $w - 20
    $leftTitle.Location = New-Object System.Drawing.Point(10, $y)
    $leftTitle.Size = New-Object System.Drawing.Size($innerW, 42)
    $y += 46

    $cdHeading.Location = New-Object System.Drawing.Point(10, $y)
    $cdHeading.Size = New-Object System.Drawing.Size($innerW, 24)
    $y += 26

    $ledH = [Math]::Min(122, [Math]::Max(76, [int]($h * 0.14)))
    $ledW = [Math]::Min(340, $w - 30)
    $ledX = [int](($w - $ledW) / 2)
    $ledY = $y + 2
    $ledPanel.Size = New-Object System.Drawing.Size($ledW, $ledH)
    $ledPanel.Location = New-Object System.Drawing.Point($ledX, $ledY)
    $y = $ledY + $ledH + 14

    $cardH = [Math]::Min(120, [Math]::Max(88, [int]($h * 0.15)))
    $cardW = [Math]::Min(340, $w - 30)
    $cardX = [int](($w - $cardW) / 2)
    $statusCard.Size = New-Object System.Drawing.Size($cardW, $cardH)
    $statusCard.Location = New-Object System.Drawing.Point($cardX, $y)

    $noteY = $h - $leftNote.Height - 12
    $minY  = $y + $cardH + 12
    if ($noteY -lt $minY) { $noteY = $minY }
    $leftNote.Location = New-Object System.Drawing.Point(18, $noteY)
}
 $left.Add_Resize({ Update-LeftLayout })
 $form.Add_Shown({ Update-LeftLayout })
Update-LeftLayout

# ===== RIGHT PANEL =====
 $right = New-Object System.Windows.Forms.Panel
 $right.Dock = "Fill"
 $right.BackColor = $red
 $right.Padding = New-Object System.Windows.Forms.Padding(14)
 $main.Controls.Add($right, 1, 0)

# panel krem berbingkai seperti area teks pada layar asli
 $paperPanel = New-Object System.Windows.Forms.Panel
 $paperPanel.Dock = "Fill"
 $paperPanel.BackColor = $paper
 $paperPanel.Padding = New-Object System.Windows.Forms.Padding(20, 16, 20, 16)
 $right.Controls.Add($paperPanel)
Enable-DoubleBuffer $paperPanel

 $paperPanel.Add_Paint({
    param($sender, $e)
    $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(140, 70, 20, 20), 2)
    $e.Graphics.DrawRectangle($pen, 1, 1, ($sender.ClientSize.Width - 2), ($sender.ClientSize.Height - 2))
    $pen.Dispose()
})

 $rightTitle = New-Object System.Windows.Forms.Label
 $rightTitle.Text = "Ooops, your files have been encrypted!"
 $rightTitle.Font = New-Object System.Drawing.Font("Arial", 19, [System.Drawing.FontStyle]::Bold)
 $rightTitle.ForeColor = [System.Drawing.Color]::DarkRed
 $rightTitle.Dock = "Top"
 $rightTitle.Height = 46
 $rightTitle.TextAlign = "MiddleLeft"
 $rightTitle.AutoSize = $false
 $paperPanel.Controls.Add($rightTitle)

 $description = New-Object System.Windows.Forms.RichTextBox
 $description.Dock = "Fill"
 $description.ReadOnly = $true
 $description.BorderStyle = "None"
 $description.BackColor = $paper
 $description.Font = New-Object System.Drawing.Font("Arial", 11)
 $description.ForeColor = $ink
 $description.Text = @"
WHAT HAPPENED TO MY COMPUTER?

This is a cybersecurity awareness simulation inspired by
the visual design of the WannaCry ransomware interface.

CAN I RECOVER MY FILES?

This is only a visual demonstration.
No files have been encrypted or modified.

WHAT SHOULD I DO?

1. Do not panic.
2. Never send money to suspicious addresses.
3. Keep regular backups of important files.
4. Update your operating system.
5. Learn how ransomware attacks work.

IMPORTANT NOTICE

This is a harmless educational demonstration.
No real ransomware activity is taking place.
"@
 $paperPanel.Controls.Add($description)

# gaya seperti aslinya: judul bagian tebal merah, isi warna gelap
 $description.SelectionStart = 0
 $description.SelectionLength = $description.Text.Length
 $description.SelectionFont = New-Object System.Drawing.Font("Arial", 11, [System.Drawing.FontStyle]::Regular)
 $description.SelectionColor = $ink

foreach ($s in @(
    'WHAT HAPPENED TO MY COMPUTER?',
    'CAN I RECOVER MY FILES?',
    'WHAT SHOULD I DO?',
    'IMPORTANT NOTICE'
)) {
    $idx = $description.Text.IndexOf($s)
    if ($idx -ge 0) {
        $description.SelectionStart = $idx
        $description.SelectionLength = $s.Length
        $description.SelectionFont = New-Object System.Drawing.Font("Arial", 12, [System.Drawing.FontStyle]::Bold)
        $description.SelectionColor = $head
    }
}
 $description.SelectionStart = 0
 $description.SelectionLength = 0

# ===== BOTTOM STATUS =====
 $footer = New-Object System.Windows.Forms.Panel
 $footer.Dock = "Bottom"
 $footer.Height = 85
 $footer.BackColor = $dark
 $form.Controls.Add($footer)
 $footer.BringToFront()

 $status = New-Object System.Windows.Forms.Label
 $status.Text = "SECURITY AWARENESS DEMONSTRATION - NO FILES AFFECTED"
 $status.ForeColor = $yellow
 $status.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
 $status.Location = New-Object System.Drawing.Point(20, 12)
 $status.AutoSize = $true
 $footer.Controls.Add($status)

 $exit = New-Object System.Windows.Forms.Button
 $exit.Text = "CLOSE SIMULATION"
 $exit.Size = New-Object System.Drawing.Size(190, 38)
 $exit.Location = New-Object System.Drawing.Point(20, 38)
 $exit.BackColor = [System.Drawing.Color]::White
 $exit.ForeColor = $dark
 $exit.FlatStyle = "Flat"
 $exit.Cursor = "Hand"
 $exit.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
 $exit.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(90, 0, 0)
 $exit.FlatAppearance.BorderSize = 1
 $exit.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(255, 230, 230)
 $exit.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::FromArgb(255, 210, 210)
 $exit.Add_Click({ $form.Close() })
 $footer.Controls.Add($exit)

# ===== COUNTDOWN (berjalan turun seperti aslinya; teks awal tetap "02:23:57") =====
# Ubah ke $false jika ingin digit diam / statis
 $script:CountdownEnabled = $true
 $script:remaining = 2 * 3600 + 23 * 60 + 57

 $countdownTimer = New-Object System.Windows.Forms.Timer
 $countdownTimer.Interval = 1000
 $countdownTimer.Add_Tick({
    if ($script:CountdownEnabled -and $script:remaining -gt 0) {
        $script:remaining--
        $ts = [TimeSpan]::FromSeconds($script:remaining)
        $script:countdownText = '{0:D2}:{1:D2}:{2:D2}' -f $ts.Hours, $ts.Minutes, $ts.Seconds
        $ledPanel.Invalidate()
    }
})
 $countdownTimer.Start()
 $form.Add_FormClosing({ $countdownTimer.Stop() })

# ===== RUN =====
[void]$form.ShowDialog()
