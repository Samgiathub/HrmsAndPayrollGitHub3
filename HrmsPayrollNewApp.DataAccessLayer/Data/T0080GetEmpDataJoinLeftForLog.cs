using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0080GetEmpDataJoinLeftForLog
{
    public int Id { get; set; }

    public string? Url { get; set; }

    public decimal? Object { get; set; }

    public string? Response { get; set; }

    public string? Body { get; set; }

    public DateTime? Timestamp { get; set; }
}
