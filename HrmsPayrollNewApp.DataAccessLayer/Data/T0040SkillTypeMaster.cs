using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040SkillTypeMaster
{
    public int SkillTypeId { get; set; }

    public int CmpId { get; set; }

    public string? SkillName { get; set; }

    public string? Description { get; set; }
}
