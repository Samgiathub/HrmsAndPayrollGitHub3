using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100SmsTranscation
{
    public decimal TranId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public DateTime? ForDate { get; set; }

    public string? ModuleName { get; set; }

    public string? SmsText { get; set; }

    public byte SendFlag { get; set; }

    public DateTime? SmsSendDate { get; set; }
}
