using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0080EmpMaster
{
    public int? IncrementEffectiveDate { get; set; }

    public decimal? BasicSalary { get; set; }

    public decimal EmpId { get; set; }

    public string? EmpCanteenCode { get; set; }

    public string? EmpDressCode { get; set; }

    public string? EmpShirtSize { get; set; }

    public string? EmpPentSize { get; set; }

    public string? EmpShoeSize { get; set; }
}
