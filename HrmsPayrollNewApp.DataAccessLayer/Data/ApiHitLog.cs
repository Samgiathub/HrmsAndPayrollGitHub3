using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class ApiHitLog
{
    public int HitId { get; set; }

    public string? ApiName { get; set; }

    public DateTime? TimeStamp { get; set; }

    public int? HitCountToday { get; set; }

    public int? HitCountTotal { get; set; }
}
