using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040MachineEfficiencyMaster
{
    public decimal EfficiencyId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? MachineId { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public virtual T0040MachineMaster? Machine { get; set; }
}
