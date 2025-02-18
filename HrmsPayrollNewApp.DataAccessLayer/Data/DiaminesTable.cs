using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class DiaminesTable
{
    public decimal? Total { get; set; }

    public decimal? Ep { get; set; }

    public decimal? AmountOfEmployeesContribution { get; set; }

    public decimal? Sub { get; set; }

    public decimal? AmountOfSubsidyBornByCompany { get; set; }

    public int? CntId { get; set; }

    public int? EmpId { get; set; }

    public string? EmpCode { get; set; }
}
