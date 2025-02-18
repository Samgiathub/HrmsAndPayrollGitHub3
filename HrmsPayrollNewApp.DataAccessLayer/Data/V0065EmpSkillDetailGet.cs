using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0065EmpSkillDetailGet
{
    public int RowId { get; set; }

    public long EmpTranId { get; set; }

    public int EmpApplicationId { get; set; }

    public int? ApprovedEmpId { get; set; }

    public DateTime? ApprovedDate { get; set; }

    public int? RptLevel { get; set; }

    public int CmpId { get; set; }

    public int SkillId { get; set; }

    public string SkillComments { get; set; } = null!;

    public string? SkillExperience { get; set; }

    public string? SkillName { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? DateOfJoin { get; set; }

    public string? EmpFullName { get; set; }

    public int BranchId { get; set; }

    public string? BranchName { get; set; }
}
