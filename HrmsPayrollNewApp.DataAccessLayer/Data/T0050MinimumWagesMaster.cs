using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050MinimumWagesMaster
{
    public int WagesId { get; set; }

    public int CmpId { get; set; }

    public int StateId { get; set; }

    public int SkillTypeId { get; set; }

    public decimal? WagesValue { get; set; }

    public DateTime? EffectiveDate { get; set; }
}
