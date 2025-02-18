using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0065EmpSkillDetailApp
{
    public long EmpTranId { get; set; }

    public int EmpApplicationId { get; set; }

    public int RowId { get; set; }

    public int CmpId { get; set; }

    public int SkillId { get; set; }

    public string SkillComments { get; set; } = null!;

    public string? SkillExperience { get; set; }

    public int? ApprovedEmpId { get; set; }

    public DateTime? ApprovedDate { get; set; }

    public int? RptLevel { get; set; }

    public virtual T0060EmpMasterApp EmpTran { get; set; } = null!;
}
