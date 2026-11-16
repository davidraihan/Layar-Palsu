Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

[System.Windows.Forms.Application]::EnableVisualStyles()

# ===== COLORS =====
$red = [System.Drawing.Color]::FromArgb(130, 0, 0)
$dark = [System.Drawing.Color]::FromArgb(85, 0, 0)
$panel = [System.Drawing.Color]::FromArgb(155, 12, 12)
$white = [System.Drawing.Color]::White
$yellow = [System.Drawing.Color]::Yellow

# ===== MAIN FORM =====
$form = New-Object System.Windows.Forms.Form
$form.Text = "WanaDecrypt0r 2.0 - SIMULATION"
$form.WindowState = "Maximized"
$form.BackColor = $red
$form.ForeColor = $white
$form.Font = New-Object System.Drawing.Font("Arial", 10)
$form.MinimumSize = New-Object System.Drawing.Size(850, 600)
$form.KeyPreview = $true
$form.StartPosition = "CenterScreen"

$form.Add_KeyDown({
    if ($_.KeyCode -eq "Escape") {
        $form.Close()
    }
})

# ===== HEADER =====
$header = New-Object System.Windows.Forms.Panel
$header.Dock = "Top"
$header.Height = 75
$header.BackColor = $dark
$form.Controls.Add($header)

$title = New-Object System.Windows.Forms.Label
$title.Text = "Wana Decrypt0r 2.0"
$title.Font = New-Object System.Drawing.Font(
    "Arial", 24, [System.Drawing.FontStyle]::Bold
)
$title.ForeColor = $white
$title.Location = New-Object System.Drawing.Point(25, 10)
$title.AutoSize = $true
$header.Controls.Add($title)

$demo = New-Object System.Windows.Forms.Label
$demo.Text = "SIMULATION / SECURITY AWARENESS DEMO"
$demo.Font = New-Object System.Drawing.Font(
    "Arial", 10, [System.Drawing.FontStyle]::Bold
)
$demo.ForeColor = $yellow
$demo.Location = New-Object System.Drawing.Point(30, 49)
$demo.AutoSize = $true
$header.Controls.Add($demo)

# ===== MAIN CONTENT =====
$main = New-Object System.Windows.Forms.TableLayoutPanel
$main.Dock = "Fill"
$main.Padding = New-Object System.Windows.Forms.Padding(18)
$main.ColumnCount = 2
$main.RowCount = 1
$main.ColumnStyles.Add(
    (New-Object System.Windows.Forms.ColumnStyle(
        [System.Windows.Forms.SizeType]::Percent, 35
    ))
)
$main.ColumnStyles.Add(
    (New-Object System.Windows.Forms.ColumnStyle(
        [System.Windows.Forms.SizeType]::Percent, 65
    ))
)
$form.Controls.Add($main)
$main.BringToFront()

# ===== LEFT PANEL =====
$left = New-Object System.Windows.Forms.Panel
$left.Dock = "Fill"
$left.BackColor = $dark
$left.Padding = New-Object System.Windows.Forms.Padding(15)
$main.Controls.Add($left, 0, 0)

$lock = New-Object System.Windows.Forms.Label
$lock.Text = "[LOCK]"
$lock.Font = New-Object System.Drawing.Font("Arial", 42, [System.Drawing.FontStyle]::Bold)
$lock.TextAlign = "MiddleCenter"
$lock.Dock = "Top"
$lock.Height = 115
$left.Controls.Add($lock)

$leftTitle = New-Object System.Windows.Forms.Label
$leftTitle.Text = "YOUR FILES ARE SAFE"
$leftTitle.Font = New-Object System.Drawing.Font(
    "Arial", 17, [System.Drawing.FontStyle]::Bold
)
$leftTitle.ForeColor = $yellow
$leftTitle.TextAlign = "MiddleCenter"
$leftTitle.Dock = "Top"
$leftTitle.Height = 55
$left.Controls.Add($leftTitle)

function Add-InfoCard {
    param($Parent, $Heading, $Value, $Y)

    $card = New-Object System.Windows.Forms.Panel
    $card.Location = New-Object System.Drawing.Point(10, $Y)
    $card.Size = New-Object System.Drawing.Size(300, 115)
    $card.Anchor = "Top,Left,Right"
    $card.BackColor = $panel
    $Parent.Controls.Add($card)

    $h = New-Object System.Windows.Forms.Label
    $h.Text = $Heading
    $h.ForeColor = $yellow
    $h.Font = New-Object System.Drawing.Font(
        "Arial", 11, [System.Drawing.FontStyle]::Bold
    )
    $h.Location = New-Object System.Drawing.Point(10, 10)
    $h.AutoSize = $true
    $card.Controls.Add($h)

    $v = New-Object System.Windows.Forms.Label
    $v.Text = $Value
    $v.ForeColor = $white
    $v.Font = New-Object System.Drawing.Font(
        "Consolas", 23, [System.Drawing.FontStyle]::Bold
    )
    $v.Location = New-Object System.Drawing.Point(10, 45)
    $v.AutoSize = $true
    $card.Controls.Add($v)
}

Add-InfoCard $left "SIMULATED COUNTDOWN" "02:23:57" 195
Add-InfoCard $left "SIMULATION STATUS" "DEMO MODE" 325

$leftNote = New-Object System.Windows.Forms.Label
$leftNote.Text = "This screen does not encrypt files.`nNo payment is required."
$leftNote.ForeColor = $yellow
$leftNote.Font = New-Object System.Drawing.Font("Arial", 10)
$leftNote.Location = New-Object System.Drawing.Point(15, 470)
$leftNote.Size = New-Object System.Drawing.Size(300, 60)
$left.Controls.Add($leftNote)

# ===== RIGHT PANEL =====
$right = New-Object System.Windows.Forms.Panel
$right.Dock = "Fill"
$right.BackColor = [System.Drawing.Color]::FromArgb(245, 235, 220)
$right.Padding = New-Object System.Windows.Forms.Padding(20)
$main.Controls.Add($right, 1, 0)

$rightTitle = New-Object System.Windows.Forms.Label
$rightTitle.Text = "Ooops, your files have been encrypted!"
$rightTitle.Font = New-Object System.Drawing.Font(
    "Arial", 19, [System.Drawing.FontStyle]::Bold
)
$rightTitle.ForeColor = [System.Drawing.Color]::DarkRed
$rightTitle.Location = New-Object System.Drawing.Point(20, 20)
$rightTitle.AutoSize = $true
$right.Controls.Add($rightTitle)

$description = New-Object System.Windows.Forms.RichTextBox
$description.Location = New-Object System.Drawing.Point(20, 75)
$description.Size = New-Object System.Drawing.Size(650, 370)
$description.Anchor = "Top,Bottom,Left,Right"
$description.ReadOnly = $true
$description.BorderStyle = "None"
$description.BackColor = [System.Drawing.Color]::FromArgb(245,235,220)
$description.Font = New-Object System.Drawing.Font("Arial", 11)
$description.ForeColor = [System.Drawing.Color]::Black
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
$right.Controls.Add($description)

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
$status.Font = New-Object System.Drawing.Font(
    "Arial", 10, [System.Drawing.FontStyle]::Bold
)
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
$exit.Font = New-Object System.Drawing.Font(
    "Arial", 10, [System.Drawing.FontStyle]::Bold
)
$exit.Add_Click({ $form.Close() })
$footer.Controls.Add($exit)

# ===== RUN =====
[void]$form.ShowDialog()
