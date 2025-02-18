using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0190DailyAdDetailImport
{
    public decimal TranId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal AdId { get; set; }

    public DateTime ImportDate { get; set; }

    public DateTime ForDate { get; set; }

    public decimal Amount { get; set; }

    public string? Comment { get; set; }
}
