using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class TmpDed
{
    public decimal EmpId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal? EmployeePf { get; set; }

    public decimal? Esic { get; set; }

    public DateTime SalGenerateDate { get; set; }

    public decimal? DamageDeduction { get; set; }

    public decimal? FineDeduction { get; set; }

    public decimal? LossDeduction { get; set; }
}
