using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class TempOtherAllowance
{
    public decimal? EmpId { get; set; }

    public decimal? AdId { get; set; }

    public DateTime? ForDate { get; set; }

    public decimal? EAdPercentage { get; set; }

    public decimal? EAdAmount { get; set; }

    public decimal? BasicSalary { get; set; }
}
