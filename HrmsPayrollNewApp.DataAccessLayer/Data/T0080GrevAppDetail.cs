using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0080GrevAppDetail
{
    public decimal GrevAppId { get; set; }

    public string? GrevAppCode { get; set; }

    public string? GrevAppName { get; set; }

    public string? GrevType { get; set; }

    public DateTime? GrevAppDate { get; set; }

    public string? GrevDesc { get; set; }

    public string? GrevEname { get; set; }

    public decimal? GrevCommittee { get; set; }

    public string? GrevCommitteeMember { get; set; }

    public DateTime? GrevMeetingDate { get; set; }

    public string? ReviewOfGrevApp { get; set; }
}
