using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0190MachineMonthlyAllowance
{
    public decimal AllowTranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal MachineId { get; set; }

    public int SalaryMonth { get; set; }

    public int SalaryYear { get; set; }

    public DateTime ForDate { get; set; }

    public decimal AllowAmount { get; set; }

    public string Comments { get; set; } = null!;

    public string MachineName { get; set; } = null!;
}
