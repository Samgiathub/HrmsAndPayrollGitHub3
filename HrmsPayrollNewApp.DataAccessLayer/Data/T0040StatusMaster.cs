using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040StatusMaster
{
    public int StatusId { get; set; }

    public string? SCode { get; set; }

    public string? STitle { get; set; }

    public int? SStatus { get; set; }

    public int? SPercentage { get; set; }

    public DateTime? SCreatedDate { get; set; }

    public DateTime? SUpdatedDate { get; set; }

    public bool? SIsDefault { get; set; }

    public bool? SIsFinal { get; set; }
}
