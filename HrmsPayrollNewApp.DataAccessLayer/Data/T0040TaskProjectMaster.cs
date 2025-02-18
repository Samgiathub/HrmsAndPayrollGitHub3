using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040TaskProjectMaster
{
    public int ProjectId { get; set; }

    public string? PrCode { get; set; }

    public string? PrTitle { get; set; }

    public int? PrStatus { get; set; }

    public DateTime? PrCreatedDate { get; set; }

    public DateTime? PrUpdatedDate { get; set; }
}
