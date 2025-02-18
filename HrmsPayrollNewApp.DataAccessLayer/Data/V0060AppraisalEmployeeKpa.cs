using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0060AppraisalEmployeeKpa
{
    public string? AlphaEmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public string EmpFirstName { get; set; } = null!;

    public decimal? DesigId { get; set; }

    public decimal? DeptId { get; set; }

    public string? DesigName { get; set; }

    public string? DeptName { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public int Status { get; set; }
}
