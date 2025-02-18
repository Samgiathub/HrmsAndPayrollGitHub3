using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0060EmpAssessmentView
{
    public decimal? EmpAssessmentViewId { get; set; }

    public int SaView { get; set; }

    public decimal BranchId { get; set; }

    public int KpaView { get; set; }

    public decimal EmpId { get; set; }

    public string? EmpFullName { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? EmpName { get; set; }

    public decimal CmpId { get; set; }

    public string? DesigName { get; set; }

    public string? DeptName { get; set; }

    public DateTime? EffectiveDate { get; set; }
}
