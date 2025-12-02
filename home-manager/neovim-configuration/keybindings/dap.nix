[
  {
    mode = "n";
    key = "<leader>rT";
    action.__raw = ''require('dap').terminate'';
    options = {
      desc = "terminate";
    };
  }
  {
    mode = "n";
    key = "<leader>rt";
    action.__raw = ''require('dap').toggle_breakpoint'';
    options = {
      desc = "Toggle Breakpoint";
    };
  }
  {
    mode = "n";
    key = "<leader>rc";
    action.__raw = ''require('dap').continue'';
    options = {
      desc = "continue";
    };
  }
  {
    mode = "n";
    key = "<leader>rs";
    action.__raw = ''require('dap').step_over'';
    options = {
      desc = "step over";
    };
  }
  {
    mode = "n";
    key = "<leader>rS";
    action.__raw = ''require('dap').step_out'';
    options = {
      desc = "step out";
    };
  }
  {
    mode = "n";
    key = "<leader>ri";
    action.__raw = ''require('dap').step_into'';
    options = {
      desc = "step into";
    };
  }
  {
    mode = "n";
    key = "<leader>rp";
    action.__raw = ''require('dap').pause'';
    options = {
      desc = "pause";
    };
  }
  {
    mode = "n";
    key = "<leader>rd";
    action.__raw = ''require('dap').down'';
    options = {
      desc = "down";
    };
  }
  {
    mode = "n";
    key = "<leader>ru";
    action.__raw = ''require('dap').up'';
    options = {
      desc = "up";
    };
  }
  # {
  #   mode = "n";
  #   key = "<leader>rc";
  #   options = {
  #     desc = "reverse continue";
  #   };
  # }
]
