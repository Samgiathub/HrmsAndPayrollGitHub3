using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090EmpSkillDetailClone
{
    public decimal RowId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal SkillId { get; set; }

    public string SkillComments { get; set; } = null!;

    public string SkillExperience { get; set; } = null!;

    public DateTime SystemDate { get; set; }

    public decimal LoginId { get; set; }
}
