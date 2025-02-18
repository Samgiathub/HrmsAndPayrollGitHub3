using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0055SkillGeneralSetting
{
    public decimal SkillId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? GradeId { get; set; }

    public decimal? DesigId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal SkillMinRate { get; set; }

    public decimal SkillMaxRate { get; set; }

    public decimal SkillTotalRate { get; set; }

    public decimal SkillDuration { get; set; }

    public virtual T0030BranchMaster? Branch { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0040DepartmentMaster? Dept { get; set; }

    public virtual T0040DesignationMaster? Desig { get; set; }

    public virtual T0040GradeMaster? Grade { get; set; }
}
