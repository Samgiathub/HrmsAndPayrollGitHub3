using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090EmpSkillDetailGet
{
    public decimal RowId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal SkillId { get; set; }

    public string SkillComments { get; set; } = null!;

    public string? SkillExperience { get; set; }

    public string? SkillName { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? DateOfJoin { get; set; }

    public string? EmpFullName { get; set; }

    public decimal BranchId { get; set; }

    public string? BranchName { get; set; }
}
