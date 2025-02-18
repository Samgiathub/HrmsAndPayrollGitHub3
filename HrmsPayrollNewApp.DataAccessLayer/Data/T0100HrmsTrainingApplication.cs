using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100HrmsTrainingApplication
{
    public decimal TrainingAppId { get; set; }

    public decimal? TrainingId { get; set; }

    public string? TrainingDesc { get; set; }

    public DateTime? ForDate { get; set; }

    public decimal? PostedEmpId { get; set; }

    public decimal? SkillId { get; set; }

    public int? AppStatus { get; set; }

    public decimal CmpId { get; set; }

    public decimal? LoginId { get; set; }

    public DateTime? SystemDate { get; set; }

    public byte TrainingPlan { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster? PostedEmp { get; set; }

    public virtual T0040SkillMaster? Skill { get; set; }

    public virtual ICollection<T0130HrmsTrainingEmployeeDetail> T0130HrmsTrainingEmployeeDetails { get; set; } = new List<T0130HrmsTrainingEmployeeDetail>();

    public virtual T0040HrmsTrainingMaster? Training { get; set; }
}
