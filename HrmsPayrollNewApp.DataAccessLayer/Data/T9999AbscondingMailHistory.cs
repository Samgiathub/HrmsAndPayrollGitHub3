using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T9999AbscondingMailHistory
{
    public decimal AbsTranId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public DateTime ReminderOneDate { get; set; }

    public byte ReminderOneSent { get; set; }

    public string? ReasonOne { get; set; }

    public DateTime? ReminderTwoDate { get; set; }

    public byte ReminderTwoSent { get; set; }

    public string? ReasonTwo { get; set; }

    public DateTime? ReminderThreeDate { get; set; }

    public byte ReminderThreeSent { get; set; }

    public string? ReasonThree { get; set; }
}
