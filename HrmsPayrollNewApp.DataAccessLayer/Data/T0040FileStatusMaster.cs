using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040FileStatusMaster
{
    public int FStatusId { get; set; }

    public string? StatusCode { get; set; }

    public string StatusTitle { get; set; } = null!;

    public DateTime? StatusCdtm { get; set; }

    public DateTime? StatusUdtm { get; set; }

    public string? StatusLog { get; set; }

    public int? IsActive { get; set; }

    public int? CmpId { get; set; }
}
