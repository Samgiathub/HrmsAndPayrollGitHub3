using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0100EmpShiftChange
{
    public decimal ShiftTranId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal ShiftId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal? ShiftType { get; set; }

    public string? ShiftType1 { get; set; }

    public decimal EmpCode { get; set; }

    public string EmpFirstName { get; set; } = null!;

    public string? EmpFullName { get; set; }

    public string ShiftName { get; set; } = null!;

    public decimal BranchId { get; set; }

    public string? BranchName { get; set; }

    public decimal? EmpSuperior { get; set; }

    public string? AlphaEmpCode { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? CatId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? SubBranchId { get; set; }

    public decimal? SegmentId { get; set; }

    public decimal GrdId { get; set; }

    public decimal? TypeId { get; set; }
}
