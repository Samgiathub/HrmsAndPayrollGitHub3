using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040NewsLetterMaster
{
    public decimal NewsLetterId { get; set; }

    public decimal CmpId { get; set; }

    public string NewsTitle { get; set; } = null!;

    public string? NewsDescription { get; set; }

    public DateTime StartDate { get; set; }

    public DateTime EndDate { get; set; }

    public byte? IsVisible { get; set; }

    public byte? FlagT { get; set; }

    public byte? FlagP { get; set; }

    public byte LoginNotification { get; set; }

    public byte IsMemberFlag { get; set; }

    public decimal? NewsAnnounEmpId { get; set; }

    public string? NewsAnnounFor { get; set; }

    public string? BranchWiseNewsAnnoun { get; set; }

    public DateTime SystemDate { get; set; }

    public string Flag { get; set; } = null!;

    public string? EmployeeName { get; set; }
}
