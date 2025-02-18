using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0100EmpGradeChange
{
    public decimal TranId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal GrdId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal EmpCode { get; set; }

    public string EmpFirstName { get; set; } = null!;

    public string? EmpFullName { get; set; }

    public string GrdName { get; set; } = null!;

    public decimal BranchId { get; set; }

    public string? BranchName { get; set; }

    public decimal? EmpSuperior { get; set; }

    public string? AlphaEmpCode { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public string DesigName { get; set; } = null!;

    public decimal? DeptId { get; set; }

    public string? DeptName { get; set; }

    public string? TypeName { get; set; }

    public string ActualGrade { get; set; } = null!;

    public string? SegmentName { get; set; }
}
