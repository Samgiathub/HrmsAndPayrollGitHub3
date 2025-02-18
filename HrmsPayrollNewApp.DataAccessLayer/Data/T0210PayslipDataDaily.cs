using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0210PayslipDataDaily
{
    public decimal PaySlipTranId { get; set; }

    public decimal? SalTranId { get; set; }

    public decimal CmpId { get; set; }

    public string? AllowanceData { get; set; }

    public string? DeductionData { get; set; }

    public decimal? TempSalTranId { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0200MonthlySalaryDaily? SalTran { get; set; }
}
