using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0000SmsLog
{
    public decimal SmsTranId { get; set; }

    public decimal EmpId { get; set; }

    public string SmsText { get; set; } = null!;

    public string Type { get; set; } = null!;

    public decimal MobileNo { get; set; }

    public DateTime SystemDate { get; set; }
}
