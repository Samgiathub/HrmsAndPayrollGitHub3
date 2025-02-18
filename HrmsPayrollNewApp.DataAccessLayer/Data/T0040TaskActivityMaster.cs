using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040TaskActivityMaster
{
    public int ActivityId { get; set; }

    public string? AmCode { get; set; }

    public string? AmTitle { get; set; }

    public int? AmStatus { get; set; }

    public DateTime? AmCreatedDate { get; set; }

    public DateTime? AmUpdatedDate { get; set; }
}
