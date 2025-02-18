using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0200HoldSalFnf
{
    public int SalHoldTranId { get; set; }

    public int CmpId { get; set; }

    public int SalTranId { get; set; }

    public string SalMonth { get; set; } = null!;

    public string SalYear { get; set; } = null!;

    public decimal SalAmount { get; set; }

    public decimal EmpId { get; set; }

    public decimal SalTranIdEffect { get; set; }
}
