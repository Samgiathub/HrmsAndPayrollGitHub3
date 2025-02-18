using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0100EmpCurrentShift
{
    public decimal ShiftTranId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal ShiftId { get; set; }

    public DateTime? ForDate { get; set; }

    public string? ShiftType { get; set; }

    public decimal EmpCode { get; set; }

    public string EmpFirstName { get; set; } = null!;

    public string? EmpFullName { get; set; }

    public string ShiftName { get; set; } = null!;

    public decimal BranchId { get; set; }

    public string? BranchName { get; set; }

    public decimal? EmpSuperior { get; set; }

    public string? AlphaEmpCode { get; set; }
}
