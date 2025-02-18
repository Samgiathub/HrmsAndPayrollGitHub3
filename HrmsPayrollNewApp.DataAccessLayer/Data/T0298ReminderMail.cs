using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0298ReminderMail
{
    public decimal ReminderId { get; set; }

    public string ReminderName { get; set; } = null!;

    public string? ReminderSp { get; set; }

    public string? Discription { get; set; }
}
