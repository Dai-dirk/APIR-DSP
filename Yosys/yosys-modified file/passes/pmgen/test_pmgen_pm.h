// Generated by pmgen.py from passes/pmgen/test_pmgen.pmg

struct test_pmgen_pm {
  Module *module;
  SigMap sigmap;
  std::function<void()> on_accept;
  bool setup_done;
  bool generate_mode;
  int accept_cnt;

  uint32_t rngseed;
  int rng(unsigned int n) {
    rngseed ^= rngseed << 13;
    rngseed ^= rngseed >> 17;
    rngseed ^= rngseed << 5;
    return rngseed % n;
  }

  typedef std::tuple<> index_1_key_type;
  typedef std::tuple<Cell*> index_1_value_type;
  dict<index_1_key_type, vector<index_1_value_type>> index_1;
  typedef std::tuple<> index_4_key_type;
  typedef std::tuple<Cell*> index_4_value_type;
  dict<index_4_key_type, vector<index_4_value_type>> index_4;
  typedef std::tuple<IdString, SigSpec> index_6_key_type;
  typedef std::tuple<Cell*> index_6_value_type;
  dict<index_6_key_type, vector<index_6_value_type>> index_6;
  typedef std::tuple<IdString, SigSpec> index_9_key_type;
  typedef std::tuple<Cell*> index_9_value_type;
  dict<index_9_key_type, vector<index_9_value_type>> index_9;
  typedef std::tuple<> index_12_key_type;
  typedef std::tuple<Cell*, IdString, IdString> index_12_value_type;
  dict<index_12_key_type, vector<index_12_value_type>> index_12;
  typedef std::tuple<SigBit> index_13_key_type;
  typedef std::tuple<Cell*, int> index_13_value_type;
  dict<index_13_key_type, vector<index_13_value_type>> index_13;
  typedef std::tuple<SigSpec, SigSpec, int> index_14_key_type;
  typedef std::tuple<Cell*, IdString, IdString> index_14_value_type;
  dict<index_14_key_type, vector<index_14_value_type>> index_14;
  typedef std::tuple<Cell*, SigBit> index_15_key_type;
  typedef std::tuple<Cell*, int> index_15_value_type;
  dict<index_15_key_type, vector<index_15_value_type>> index_15;
  dict<SigBit, pool<Cell*>> sigusers;
  pool<Cell*> blacklist_cells;
  pool<Cell*> autoremove_cells;
  dict<Cell*,int> rollback_cache;
  int rollback;

  struct state_eqpmux_t {
    Cell* eq;
    SigSpec eq_inA;
    SigSpec eq_inB;
    bool eq_ne_signed;
    Cell* ne;
    Cell* pmux;
    Cell* pmux2;
    int pmux_slice_eq;
    int pmux_slice_ne;
  } st_eqpmux;

  struct udata_eqpmux_t {
  } ud_eqpmux;

  struct state_reduce_t {
    Cell* first;
    Cell* next;
    IdString portname;
  } st_reduce;

  struct udata_reduce_t {
    vector<pair<Cell*, IdString>> chain;
    SigSpec leaves;
    vector<pair<Cell*, IdString>> longest_chain;
    pool<Cell*> non_first_cells;
  } ud_reduce;

  IdString id_b_A{"\\A"};
  IdString id_b_A_SIGNED{"\\A_SIGNED"};
  IdString id_b_B{"\\B"};
  IdString id_b_S{"\\S"};
  IdString id_b_Y{"\\Y"};
  IdString id_d__AND_{"$_AND_"};
  IdString id_d__OR_{"$_OR_"};
  IdString id_d__XOR_{"$_XOR_"};
  IdString id_d_eq{"$eq"};
  IdString id_d_ne{"$ne"};
  IdString id_d_pmux{"$pmux"};

  void add_siguser(const SigSpec &sig, Cell *cell) {
    for (auto bit : sigmap(sig)) {
      if (bit.wire == nullptr) continue;
      sigusers[bit].insert(cell);
    }
  }

  void blacklist(Cell *cell) {
    if (cell != nullptr && blacklist_cells.insert(cell).second) {
      auto ptr = rollback_cache.find(cell);
      if (ptr == rollback_cache.end()) return;
      int rb = ptr->second;
      if (rollback == 0 || rollback > rb)
        rollback = rb;
    }
  }

  void autoremove(Cell *cell) {
    if (cell != nullptr) {
      autoremove_cells.insert(cell);
      blacklist(cell);
    }
  }

  SigSpec port(Cell *cell, IdString portname) {
    return sigmap(cell->getPort(portname));
  }

  SigSpec port(Cell *cell, IdString portname, const SigSpec& defval) {
    return sigmap(cell->connections_.at(portname, defval));
  }

  Const param(Cell *cell, IdString paramname) {
    return cell->getParam(paramname);
  }

  Const param(Cell *cell, IdString paramname, const Const& defval) {
    return cell->parameters.at(paramname, defval);
  }

  int nusers(const SigSpec &sig) {
    pool<Cell*> users;
    for (auto bit : sigmap(sig))
      for (auto user : sigusers[bit])
        users.insert(user);
    return GetSize(users);
  }

  test_pmgen_pm(Module *module, const vector<Cell*> &cells) :
      module(module), sigmap(module), setup_done(false), generate_mode(false), rngseed(12345678) {
    setup(cells);
  }

  test_pmgen_pm(Module *module) :
      module(module), sigmap(module), setup_done(false), generate_mode(false), rngseed(12345678) {
  }

  void setup(const vector<Cell*> &cells) {
    ud_reduce.chain = vector<pair<Cell*, IdString>>();
    ud_reduce.leaves = SigSpec();
    ud_reduce.longest_chain = vector<pair<Cell*, IdString>>();
    ud_reduce.non_first_cells = pool<Cell*>();
    log_assert(!setup_done);
    setup_done = true;
    for (auto port : module->ports)
      add_siguser(module->wire(port), nullptr);
    for (auto cell : module->cells())
      for (auto &conn : cell->connections())
        add_siguser(conn.second, cell);
    for (auto cell : cells) {
      do {
        Cell *first = cell;
        index_1_value_type value;
        std::get<0>(value) = cell;
        if (!(first->type.in(id_d__AND_, id_d__OR_, id_d__XOR_))) continue;
        index_1_key_type key;
        index_1[key].push_back(value);
      } while (0);
      do {
        Cell *first = cell;
        index_4_value_type value;
        std::get<0>(value) = cell;
        if (!(first->type.in(id_d__AND_, id_d__OR_, id_d__XOR_))) continue;
        index_4_key_type key;
        index_4[key].push_back(value);
      } while (0);
      do {
        Cell *next = cell;
        index_6_value_type value;
        std::get<0>(value) = cell;
        if (!(next->type.in(id_d__AND_, id_d__OR_, id_d__XOR_))) continue;
        if (!(nusers(port(next, id_b_Y)) == 2)) continue;
        index_6_key_type key;
        std::get<0>(key) = next->type;
        std::get<1>(key) = port(next, id_b_Y);
        index_6[key].push_back(value);
      } while (0);
      do {
        Cell *next = cell;
        index_9_value_type value;
        std::get<0>(value) = cell;
        if (!(next->type.in(id_d__AND_, id_d__OR_, id_d__XOR_))) continue;
        if (!(nusers(port(next, id_b_Y)) == 2)) continue;
        index_9_key_type key;
        std::get<0>(key) = next->type;
        std::get<1>(key) = port(next, id_b_Y);
        index_9[key].push_back(value);
      } while (0);
      do {
        Cell *eq = cell;
        index_12_value_type value;
        std::get<0>(value) = cell;
        if (!(eq->type == id_d_eq)) continue;
        vector<IdString> _pmg_choices_AB = {id_b_A, id_b_B};
        for (const IdString &AB : _pmg_choices_AB) {
        std::get<1>(value) = AB;
        IdString &BA = std::get<2>(value);
        BA = AB == id_b_A ? id_b_B : id_b_A;
        index_12_key_type key;
        index_12[key].push_back(value);
        }
      } while (0);
      do {
        Cell *pmux = cell;
        index_13_value_type value;
        std::get<0>(value) = cell;
        if (!(pmux->type == id_d_pmux)) continue;
        int &idx = std::get<1>(value);
        for (idx = 0; idx < GetSize(port(pmux, id_b_S)); idx++) {
        index_13_key_type key;
        std::get<0>(key) = port(pmux, id_b_S)[idx];
        index_13[key].push_back(value);
        }
      } while (0);
      do {
        Cell *ne = cell;
        index_14_value_type value;
        std::get<0>(value) = cell;
        if (!(ne->type == id_d_ne)) continue;
        vector<IdString> _pmg_choices_AB = {id_b_A, id_b_B};
        for (const IdString &AB : _pmg_choices_AB) {
        std::get<1>(value) = AB;
        IdString &BA = std::get<2>(value);
        BA = (AB == id_b_A ? id_b_B : id_b_A);
        index_14_key_type key;
        std::get<0>(key) = port(ne, AB);
        std::get<1>(key) = port(ne, BA);
        std::get<2>(key) = param(ne, id_b_A_SIGNED).as_bool();
        index_14[key].push_back(value);
        }
      } while (0);
      do {
        Cell *pmux2 = cell;
        index_15_value_type value;
        std::get<0>(value) = cell;
        if (!(pmux2->type == id_d_pmux)) continue;
        int &idx = std::get<1>(value);
        for (idx = 0; idx < GetSize(port(pmux2, id_b_S)); idx++) {
        index_15_key_type key;
        std::get<0>(key) = pmux2;
        std::get<1>(key) = port(pmux2, id_b_S)[idx];
        index_15[key].push_back(value);
        }
      } while (0);
    }
  }

  ~test_pmgen_pm() {
    for (auto cell : autoremove_cells)
      module->remove(cell);
  }

  int run_eqpmux(std::function<void()> on_accept_f) {
    log_assert(setup_done);
    accept_cnt = 0;
    on_accept = on_accept_f;
    rollback = 0;
    st_eqpmux.eq = nullptr;
    st_eqpmux.eq_inA = SigSpec();
    st_eqpmux.eq_inB = SigSpec();
    st_eqpmux.eq_ne_signed = bool();
    st_eqpmux.ne = nullptr;
    st_eqpmux.pmux = nullptr;
    st_eqpmux.pmux2 = nullptr;
    st_eqpmux.pmux_slice_eq = int();
    st_eqpmux.pmux_slice_ne = int();
    block_12(1);
    log_assert(rollback_cache.empty());
    return accept_cnt;
  }

  int run_eqpmux(std::function<void(test_pmgen_pm&)> on_accept_f) {
    return run_eqpmux([&](){on_accept_f(*this);});
  }

  int run_eqpmux() {
    return run_eqpmux([](){});
  }

  int run_reduce(std::function<void()> on_accept_f) {
    log_assert(setup_done);
    accept_cnt = 0;
    on_accept = on_accept_f;
    rollback = 0;
    st_reduce.first = nullptr;
    st_reduce.next = nullptr;
    st_reduce.portname = IdString();
    block_0(1);
    log_assert(rollback_cache.empty());
    return accept_cnt;
  }

  int run_reduce(std::function<void(test_pmgen_pm&)> on_accept_f) {
    return run_reduce([&](){on_accept_f(*this);});
  }

  int run_reduce() {
    return run_reduce([](){});
  }

  void block_subpattern_eqpmux_(int recursion) { block_12(recursion); }
  void block_subpattern_reduce_(int recursion) { block_0(recursion); }
  void block_subpattern_reduce_setup(int recursion) { block_4(recursion); }
  void block_subpattern_reduce_tail(int recursion) { block_9(recursion); }

  // passes/pmgen/test_pmgen.pmg:8
  void block_0(int recursion YS_MAYBE_UNUSED) {
    vector<pair<Cell*, IdString>> &chain YS_MAYBE_UNUSED = ud_reduce.chain;
    SigSpec &leaves YS_MAYBE_UNUSED = ud_reduce.leaves;
    vector<pair<Cell*, IdString>> &longest_chain YS_MAYBE_UNUSED = ud_reduce.longest_chain;
    pool<Cell*> &non_first_cells YS_MAYBE_UNUSED = ud_reduce.non_first_cells;

#define reject do { goto rollback_label; } while(0)
#define accept do { accept_cnt++; on_accept(); if (rollback) goto rollback_label; } while(0)
#define finish do { rollback = -1; goto rollback_label; } while(0)
#define branch do { block_1(recursion+1); if (rollback) goto rollback_label; } while(0)
#define subpattern(pattern_name) do { block_subpattern_reduce_ ## pattern_name (recursion+1); if (rollback) goto rollback_label; } while(0)
    non_first_cells.clear();
    subpattern(setup);

    block_1(recursion+1);
#undef reject
#undef accept
#undef finish
#undef branch
#undef subpattern

rollback_label:
    YS_MAYBE_UNUSED;
  }

  // passes/pmgen/test_pmgen.pmg:13
  void block_1(int recursion YS_MAYBE_UNUSED) {
    Cell* &first YS_MAYBE_UNUSED = st_reduce.first;
    vector<pair<Cell*, IdString>> &chain YS_MAYBE_UNUSED = ud_reduce.chain;
    SigSpec &leaves YS_MAYBE_UNUSED = ud_reduce.leaves;
    vector<pair<Cell*, IdString>> &longest_chain YS_MAYBE_UNUSED = ud_reduce.longest_chain;
    pool<Cell*> &non_first_cells YS_MAYBE_UNUSED = ud_reduce.non_first_cells;
    Cell* _pmg_backup_first = first;

    index_1_key_type key;
    auto cells_ptr = index_1.find(key);
    bool found_any_match = false;

    if (cells_ptr != index_1.end()) {
      const vector<index_1_value_type> &cells = cells_ptr->second;
      for (int _pmg_idx = 0; _pmg_idx < GetSize(cells); _pmg_idx++) {
        first = std::get<0>(cells[_pmg_idx]);
        if (blacklist_cells.count(first)) continue;
        if (!(!non_first_cells.count(first))) continue;
        found_any_match = true;
        auto rollback_ptr = rollback_cache.insert(make_pair(std::get<0>(cells[_pmg_idx]), recursion));
        block_2(recursion+1);
        if (rollback_ptr.second)
          rollback_cache.erase(rollback_ptr.first);
        if (rollback) {
          if (rollback != recursion) {
            first = _pmg_backup_first;
            return;
          }
          rollback = 0;
        }
      }
    }

    first = nullptr;
    first = _pmg_backup_first;
#define finish do { rollback = -1; return; } while(0)
    if (generate_mode && rng(100) < (found_any_match ? 0 : 100)) {
        SigSpec A = module->addWire(NEW_ID);
        SigSpec B = module->addWire(NEW_ID);
        SigSpec Y = module->addWire(NEW_ID);
        switch (rng(3))
        {
        case 0:
          module->addAndGate(NEW_ID, A, B, Y);
          break;
        case 1:
          module->addOrGate(NEW_ID, A, B, Y);
          break;
        case 2:
          module->addXorGate(NEW_ID, A, B, Y);
          break;
        }
    }
#undef finish
  }

  // passes/pmgen/test_pmgen.pmg:34
  void block_2(int recursion YS_MAYBE_UNUSED) {
    Cell* const &first YS_MAYBE_UNUSED = st_reduce.first;
    vector<pair<Cell*, IdString>> &chain YS_MAYBE_UNUSED = ud_reduce.chain;
    SigSpec &leaves YS_MAYBE_UNUSED = ud_reduce.leaves;
    vector<pair<Cell*, IdString>> &longest_chain YS_MAYBE_UNUSED = ud_reduce.longest_chain;
    pool<Cell*> &non_first_cells YS_MAYBE_UNUSED = ud_reduce.non_first_cells;

#define reject do { goto rollback_label; } while(0)
#define accept do { accept_cnt++; on_accept(); if (rollback) goto rollback_label; } while(0)
#define finish do { rollback = -1; goto rollback_label; } while(0)
#define branch do { block_3(recursion+1); if (rollback) goto rollback_label; } while(0)
#define subpattern(pattern_name) do { block_subpattern_reduce_ ## pattern_name (recursion+1); if (rollback) goto rollback_label; } while(0)
    leaves = SigSpec();
    longest_chain.clear();
    chain.push_back(make_pair(first, id_b_A));
    subpattern(tail);
    chain.back().second = id_b_B;
    subpattern(tail);

    block_3(recursion+1);
#undef reject
#undef accept
#undef finish
#undef branch
#undef subpattern

rollback_label:
    YS_MAYBE_UNUSED;
#define accept do { accept_cnt++; on_accept(); } while(0)
#define finish do { rollback = -1; goto finish_label; } while(0)
    chain.pop_back();
    log_assert(chain.empty());
    if (GetSize(longest_chain) > 1)
      accept;
finish_label:
    YS_MAYBE_UNUSED;
#undef accept
#undef finish
  }

  void block_3(int recursion YS_MAYBE_UNUSED) {
  }

  // passes/pmgen/test_pmgen.pmg:52
  void block_4(int recursion YS_MAYBE_UNUSED) {
    Cell* &first YS_MAYBE_UNUSED = st_reduce.first;
    vector<pair<Cell*, IdString>> &chain YS_MAYBE_UNUSED = ud_reduce.chain;
    SigSpec &leaves YS_MAYBE_UNUSED = ud_reduce.leaves;
    vector<pair<Cell*, IdString>> &longest_chain YS_MAYBE_UNUSED = ud_reduce.longest_chain;
    pool<Cell*> &non_first_cells YS_MAYBE_UNUSED = ud_reduce.non_first_cells;
    Cell* _pmg_backup_first = first;

    index_4_key_type key;
    auto cells_ptr = index_4.find(key);

    if (cells_ptr != index_4.end()) {
      const vector<index_4_value_type> &cells = cells_ptr->second;
      for (int _pmg_idx = 0; _pmg_idx < GetSize(cells); _pmg_idx++) {
        first = std::get<0>(cells[_pmg_idx]);
        if (blacklist_cells.count(first)) continue;
        auto rollback_ptr = rollback_cache.insert(make_pair(std::get<0>(cells[_pmg_idx]), recursion));
        block_5(recursion+1);
        if (rollback_ptr.second)
          rollback_cache.erase(rollback_ptr.first);
        if (rollback) {
          if (rollback != recursion) {
            first = _pmg_backup_first;
            return;
          }
          rollback = 0;
        }
      }
    }

    first = nullptr;
    first = _pmg_backup_first;
  }

  // passes/pmgen/test_pmgen.pmg:56
  void block_5(int recursion YS_MAYBE_UNUSED) {
    Cell* const &first YS_MAYBE_UNUSED = st_reduce.first;
    IdString &portname YS_MAYBE_UNUSED = st_reduce.portname;
    vector<pair<Cell*, IdString>> &chain YS_MAYBE_UNUSED = ud_reduce.chain;
    SigSpec &leaves YS_MAYBE_UNUSED = ud_reduce.leaves;
    vector<pair<Cell*, IdString>> &longest_chain YS_MAYBE_UNUSED = ud_reduce.longest_chain;
    pool<Cell*> &non_first_cells YS_MAYBE_UNUSED = ud_reduce.non_first_cells;

#define reject do { goto rollback_label; } while(0)
#define accept do { accept_cnt++; on_accept(); if (rollback) goto rollback_label; } while(0)
#define finish do { rollback = -1; goto rollback_label; } while(0)
#define branch do { block_6(recursion+1); if (rollback) goto rollback_label; } while(0)
#define subpattern(pattern_name) do { block_subpattern_reduce_ ## pattern_name (recursion+1); if (rollback) goto rollback_label; } while(0)
    portname = id_b_A;
    branch;
    portname = id_b_B;

    block_6(recursion+1);
#undef reject
#undef accept
#undef finish
#undef branch
#undef subpattern

rollback_label:
    YS_MAYBE_UNUSED;

    portname = IdString();
  }

  // passes/pmgen/test_pmgen.pmg:62
  void block_6(int recursion YS_MAYBE_UNUSED) {
    Cell* const &first YS_MAYBE_UNUSED = st_reduce.first;
    const IdString &portname YS_MAYBE_UNUSED = st_reduce.portname;
    Cell* &next YS_MAYBE_UNUSED = st_reduce.next;
    vector<pair<Cell*, IdString>> &chain YS_MAYBE_UNUSED = ud_reduce.chain;
    SigSpec &leaves YS_MAYBE_UNUSED = ud_reduce.leaves;
    vector<pair<Cell*, IdString>> &longest_chain YS_MAYBE_UNUSED = ud_reduce.longest_chain;
    pool<Cell*> &non_first_cells YS_MAYBE_UNUSED = ud_reduce.non_first_cells;
    Cell* _pmg_backup_next = next;

    index_6_key_type key;
    std::get<0>(key) = first->type;
    std::get<1>(key) = port(first, portname);
    auto cells_ptr = index_6.find(key);

    if (cells_ptr != index_6.end()) {
      const vector<index_6_value_type> &cells = cells_ptr->second;
      for (int _pmg_idx = 0; _pmg_idx < GetSize(cells); _pmg_idx++) {
        next = std::get<0>(cells[_pmg_idx]);
        if (blacklist_cells.count(next)) continue;
        auto rollback_ptr = rollback_cache.insert(make_pair(std::get<0>(cells[_pmg_idx]), recursion));
        block_7(recursion+1);
        if (rollback_ptr.second)
          rollback_cache.erase(rollback_ptr.first);
        if (rollback) {
          if (rollback != recursion) {
            next = _pmg_backup_next;
            return;
          }
          rollback = 0;
        }
      }
    }

    next = nullptr;
    next = _pmg_backup_next;
  }

  // passes/pmgen/test_pmgen.pmg:69
  void block_7(int recursion YS_MAYBE_UNUSED) {
    Cell* const &first YS_MAYBE_UNUSED = st_reduce.first;
    Cell* const &next YS_MAYBE_UNUSED = st_reduce.next;
    const IdString &portname YS_MAYBE_UNUSED = st_reduce.portname;
    vector<pair<Cell*, IdString>> &chain YS_MAYBE_UNUSED = ud_reduce.chain;
    SigSpec &leaves YS_MAYBE_UNUSED = ud_reduce.leaves;
    vector<pair<Cell*, IdString>> &longest_chain YS_MAYBE_UNUSED = ud_reduce.longest_chain;
    pool<Cell*> &non_first_cells YS_MAYBE_UNUSED = ud_reduce.non_first_cells;

#define reject do { goto rollback_label; } while(0)
#define accept do { accept_cnt++; on_accept(); if (rollback) goto rollback_label; } while(0)
#define finish do { rollback = -1; goto rollback_label; } while(0)
#define branch do { block_8(recursion+1); if (rollback) goto rollback_label; } while(0)
#define subpattern(pattern_name) do { block_subpattern_reduce_ ## pattern_name (recursion+1); if (rollback) goto rollback_label; } while(0)
    non_first_cells.insert(next);

    block_8(recursion+1);
#undef reject
#undef accept
#undef finish
#undef branch
#undef subpattern

rollback_label:
    YS_MAYBE_UNUSED;
  }

  void block_8(int recursion YS_MAYBE_UNUSED) {
  }

  // passes/pmgen/test_pmgen.pmg:78
  void block_9(int recursion YS_MAYBE_UNUSED) {
    Cell* const &first YS_MAYBE_UNUSED = st_reduce.first;
    Cell* &next YS_MAYBE_UNUSED = st_reduce.next;
    vector<pair<Cell*, IdString>> &chain YS_MAYBE_UNUSED = ud_reduce.chain;
    SigSpec &leaves YS_MAYBE_UNUSED = ud_reduce.leaves;
    vector<pair<Cell*, IdString>> &longest_chain YS_MAYBE_UNUSED = ud_reduce.longest_chain;
    pool<Cell*> &non_first_cells YS_MAYBE_UNUSED = ud_reduce.non_first_cells;
    Cell* _pmg_backup_next = next;

    index_9_key_type key;
    std::get<0>(key) = chain.back().first->type;
    std::get<1>(key) = port(chain.back().first, chain.back().second);
    auto cells_ptr = index_9.find(key);
    bool found_any_match = false;

    if (cells_ptr != index_9.end()) {
      const vector<index_9_value_type> &cells = cells_ptr->second;
      for (int _pmg_idx = 0; _pmg_idx < GetSize(cells); _pmg_idx++) {
        next = std::get<0>(cells[_pmg_idx]);
        if (blacklist_cells.count(next)) continue;
        found_any_match = true;
        auto rollback_ptr = rollback_cache.insert(make_pair(std::get<0>(cells[_pmg_idx]), recursion));
        block_10(recursion+1);
        if (rollback_ptr.second)
          rollback_cache.erase(rollback_ptr.first);
        if (rollback) {
          if (rollback != recursion) {
            next = _pmg_backup_next;
            return;
          }
          rollback = 0;
        }
      }
    }

    next = nullptr;
    if (!found_any_match) block_10(recursion+1);
    next = _pmg_backup_next;
#define finish do { rollback = -1; return; } while(0)
    if (generate_mode && rng(100) < (found_any_match ? 0 : 10)) {
        SigSpec A = module->addWire(NEW_ID);
        SigSpec B = module->addWire(NEW_ID);
        SigSpec Y = port(chain.back().first, chain.back().second);
        Cell *c = module->addAndGate(NEW_ID, A, B, Y);
        c->type = chain.back().first->type;
    }
#undef finish
  }

  // passes/pmgen/test_pmgen.pmg:92
  void block_10(int recursion YS_MAYBE_UNUSED) {
    Cell* const &first YS_MAYBE_UNUSED = st_reduce.first;
    Cell* const &next YS_MAYBE_UNUSED = st_reduce.next;
    vector<pair<Cell*, IdString>> &chain YS_MAYBE_UNUSED = ud_reduce.chain;
    SigSpec &leaves YS_MAYBE_UNUSED = ud_reduce.leaves;
    vector<pair<Cell*, IdString>> &longest_chain YS_MAYBE_UNUSED = ud_reduce.longest_chain;
    pool<Cell*> &non_first_cells YS_MAYBE_UNUSED = ud_reduce.non_first_cells;

#define reject do { goto rollback_label; } while(0)
#define accept do { accept_cnt++; on_accept(); if (rollback) goto rollback_label; } while(0)
#define finish do { rollback = -1; goto rollback_label; } while(0)
#define branch do { block_11(recursion+1); if (rollback) goto rollback_label; } while(0)
#define subpattern(pattern_name) do { block_subpattern_reduce_ ## pattern_name (recursion+1); if (rollback) goto rollback_label; } while(0)
    if (next) {
      chain.push_back(make_pair(next, id_b_A));
      subpattern(tail);
      chain.back().second = id_b_B;
      subpattern(tail);
    } else {
      if (GetSize(chain) > GetSize(longest_chain))
        longest_chain = chain;
      leaves.append(port(chain.back().first, chain.back().second));
    }

    block_11(recursion+1);
#undef reject
#undef accept
#undef finish
#undef branch
#undef subpattern

rollback_label:
    YS_MAYBE_UNUSED;
#define accept do { accept_cnt++; on_accept(); } while(0)
#define finish do { rollback = -1; goto finish_label; } while(0)
    if (next)
      chain.pop_back();
finish_label:
    YS_MAYBE_UNUSED;
#undef accept
#undef finish
  }

  void block_11(int recursion YS_MAYBE_UNUSED) {
  }

  // passes/pmgen/test_pmgen.pmg:116
  void block_12(int recursion YS_MAYBE_UNUSED) {
    Cell* &eq YS_MAYBE_UNUSED = st_eqpmux.eq;
    SigSpec &eq_inA YS_MAYBE_UNUSED = st_eqpmux.eq_inA;
    SigSpec &eq_inB YS_MAYBE_UNUSED = st_eqpmux.eq_inB;
    bool &eq_ne_signed YS_MAYBE_UNUSED = st_eqpmux.eq_ne_signed;
    Cell* _pmg_backup_eq = eq;

    index_12_key_type key;
    auto cells_ptr = index_12.find(key);
    bool found_any_match = false;

    if (cells_ptr != index_12.end()) {
      const vector<index_12_value_type> &cells = cells_ptr->second;
      for (int _pmg_idx = 0; _pmg_idx < GetSize(cells); _pmg_idx++) {
        eq = std::get<0>(cells[_pmg_idx]);
        const IdString &AB YS_MAYBE_UNUSED = std::get<1>(cells[_pmg_idx]);
        const IdString &BA YS_MAYBE_UNUSED = std::get<2>(cells[_pmg_idx]);
        if (blacklist_cells.count(eq)) continue;
        found_any_match = true;
        auto _pmg_backup_eq_inA = eq_inA;
        eq_inA = port(eq, id_b_A);
        auto _pmg_backup_eq_inB = eq_inB;
        eq_inB = port(eq, id_b_B);
        auto _pmg_backup_eq_ne_signed = eq_ne_signed;
        eq_ne_signed = param(eq, id_b_A_SIGNED).as_bool();
        auto rollback_ptr = rollback_cache.insert(make_pair(std::get<0>(cells[_pmg_idx]), recursion));
        block_13(recursion+1);
        eq_inA = _pmg_backup_eq_inA;
        eq_inB = _pmg_backup_eq_inB;
        eq_ne_signed = _pmg_backup_eq_ne_signed;
        if (rollback_ptr.second)
          rollback_cache.erase(rollback_ptr.first);
        if (rollback) {
          if (rollback != recursion) {
            eq = _pmg_backup_eq;
            return;
          }
          rollback = 0;
        }
      }
    }

    eq = nullptr;
    eq = _pmg_backup_eq;
#define finish do { rollback = -1; return; } while(0)
    if (generate_mode && rng(100) < (found_any_match ? 10 : 100)) {
        SigSpec A = module->addWire(NEW_ID, rng(7)+1);
        SigSpec B = module->addWire(NEW_ID, rng(7)+1);
        SigSpec Y = module->addWire(NEW_ID);
        module->addEq(NEW_ID, A, B, Y, rng(2));
    }
#undef finish
  }

  // passes/pmgen/test_pmgen.pmg:130
  void block_13(int recursion YS_MAYBE_UNUSED) {
    Cell* const &eq YS_MAYBE_UNUSED = st_eqpmux.eq;
    const SigSpec &eq_inA YS_MAYBE_UNUSED = st_eqpmux.eq_inA;
    const SigSpec &eq_inB YS_MAYBE_UNUSED = st_eqpmux.eq_inB;
    const bool &eq_ne_signed YS_MAYBE_UNUSED = st_eqpmux.eq_ne_signed;
    Cell* &pmux YS_MAYBE_UNUSED = st_eqpmux.pmux;
    int &pmux_slice_eq YS_MAYBE_UNUSED = st_eqpmux.pmux_slice_eq;
    Cell* _pmg_backup_pmux = pmux;

    index_13_key_type key;
    std::get<0>(key) = port(eq, id_b_Y);
    auto cells_ptr = index_13.find(key);
    bool found_any_match = false;

    if (cells_ptr != index_13.end()) {
      const vector<index_13_value_type> &cells = cells_ptr->second;
      for (int _pmg_idx = 0; _pmg_idx < GetSize(cells); _pmg_idx++) {
        pmux = std::get<0>(cells[_pmg_idx]);
        const int &idx YS_MAYBE_UNUSED = std::get<1>(cells[_pmg_idx]);
        if (blacklist_cells.count(pmux)) continue;
        found_any_match = true;
        auto _pmg_backup_pmux_slice_eq = pmux_slice_eq;
        pmux_slice_eq = idx;
        auto rollback_ptr = rollback_cache.insert(make_pair(std::get<0>(cells[_pmg_idx]), recursion));
        block_14(recursion+1);
        pmux_slice_eq = _pmg_backup_pmux_slice_eq;
        if (rollback_ptr.second)
          rollback_cache.erase(rollback_ptr.first);
        if (rollback) {
          if (rollback != recursion) {
            pmux = _pmg_backup_pmux;
            return;
          }
          rollback = 0;
        }
      }
    }

    pmux = nullptr;
    pmux = _pmg_backup_pmux;
#define finish do { rollback = -1; return; } while(0)
    if (generate_mode && rng(100) < (found_any_match ? 10 : 100)) {
        int width = rng(7) + 1;
        int numsel = rng(4) + 1;
        int idx = rng(numsel);
      
        SigSpec A = module->addWire(NEW_ID, width);
        SigSpec Y = module->addWire(NEW_ID, width);
      
        SigSpec B, S;
        for (int i = 0; i < numsel; i++) {
          B.append(module->addWire(NEW_ID, width));
          S.append(i == idx ? port(eq, id_b_Y) : module->addWire(NEW_ID));
        }
      
        module->addPmux(NEW_ID, A, B, S, Y);
    }
#undef finish
  }

  // passes/pmgen/test_pmgen.pmg:152
  void block_14(int recursion YS_MAYBE_UNUSED) {
    Cell* const &eq YS_MAYBE_UNUSED = st_eqpmux.eq;
    const SigSpec &eq_inA YS_MAYBE_UNUSED = st_eqpmux.eq_inA;
    const SigSpec &eq_inB YS_MAYBE_UNUSED = st_eqpmux.eq_inB;
    const bool &eq_ne_signed YS_MAYBE_UNUSED = st_eqpmux.eq_ne_signed;
    Cell* const &pmux YS_MAYBE_UNUSED = st_eqpmux.pmux;
    const int &pmux_slice_eq YS_MAYBE_UNUSED = st_eqpmux.pmux_slice_eq;
    Cell* &ne YS_MAYBE_UNUSED = st_eqpmux.ne;
    Cell* _pmg_backup_ne = ne;

    index_14_key_type key;
    std::get<0>(key) = eq_inA;
    std::get<1>(key) = eq_inB;
    std::get<2>(key) = eq_ne_signed;
    auto cells_ptr = index_14.find(key);
    bool found_any_match = false;

    if (cells_ptr != index_14.end()) {
      const vector<index_14_value_type> &cells = cells_ptr->second;
      for (int _pmg_idx = 0; _pmg_idx < GetSize(cells); _pmg_idx++) {
        ne = std::get<0>(cells[_pmg_idx]);
        const IdString &AB YS_MAYBE_UNUSED = std::get<1>(cells[_pmg_idx]);
        const IdString &BA YS_MAYBE_UNUSED = std::get<2>(cells[_pmg_idx]);
        if (blacklist_cells.count(ne)) continue;
        found_any_match = true;
        auto rollback_ptr = rollback_cache.insert(make_pair(std::get<0>(cells[_pmg_idx]), recursion));
        block_15(recursion+1);
        if (rollback_ptr.second)
          rollback_cache.erase(rollback_ptr.first);
        if (rollback) {
          if (rollback != recursion) {
            ne = _pmg_backup_ne;
            return;
          }
          rollback = 0;
        }
      }
    }

    ne = nullptr;
    ne = _pmg_backup_ne;
#define finish do { rollback = -1; return; } while(0)
    if (generate_mode && rng(100) < (found_any_match ? 10 : 100)) {
        SigSpec A = eq_inA, B = eq_inB, Y;
        if (rng(2)) {
          std::swap(A, B);
        }
        if (rng(2)) {
          for (auto bit : port(pmux, id_b_S)) {
            if (nusers(bit) < 2)
              Y.append(bit);
          }
          if (GetSize(Y))
            Y = Y[rng(GetSize(Y))];
          else
            Y = module->addWire(NEW_ID);
        } else {
          Y = module->addWire(NEW_ID);
        }
        module->addNe(NEW_ID, A, B, Y, rng(2));
    }
#undef finish
  }

  // passes/pmgen/test_pmgen.pmg:179
  void block_15(int recursion YS_MAYBE_UNUSED) {
    Cell* const &eq YS_MAYBE_UNUSED = st_eqpmux.eq;
    const SigSpec &eq_inA YS_MAYBE_UNUSED = st_eqpmux.eq_inA;
    const SigSpec &eq_inB YS_MAYBE_UNUSED = st_eqpmux.eq_inB;
    const bool &eq_ne_signed YS_MAYBE_UNUSED = st_eqpmux.eq_ne_signed;
    Cell* const &ne YS_MAYBE_UNUSED = st_eqpmux.ne;
    Cell* const &pmux YS_MAYBE_UNUSED = st_eqpmux.pmux;
    const int &pmux_slice_eq YS_MAYBE_UNUSED = st_eqpmux.pmux_slice_eq;
    Cell* &pmux2 YS_MAYBE_UNUSED = st_eqpmux.pmux2;
    int &pmux_slice_ne YS_MAYBE_UNUSED = st_eqpmux.pmux_slice_ne;
    Cell* _pmg_backup_pmux2 = pmux2;

    index_15_key_type key;
    std::get<0>(key) = pmux;
    std::get<1>(key) = port(ne, id_b_Y);
    auto cells_ptr = index_15.find(key);

    if (cells_ptr != index_15.end()) {
      const vector<index_15_value_type> &cells = cells_ptr->second;
      for (int _pmg_idx = 0; _pmg_idx < GetSize(cells); _pmg_idx++) {
        pmux2 = std::get<0>(cells[_pmg_idx]);
        const int &idx YS_MAYBE_UNUSED = std::get<1>(cells[_pmg_idx]);
        if (blacklist_cells.count(pmux2)) continue;
        auto _pmg_backup_pmux_slice_ne = pmux_slice_ne;
        pmux_slice_ne = idx;
        auto rollback_ptr = rollback_cache.insert(make_pair(std::get<0>(cells[_pmg_idx]), recursion));
        block_16(recursion+1);
        pmux_slice_ne = _pmg_backup_pmux_slice_ne;
        if (rollback_ptr.second)
          rollback_cache.erase(rollback_ptr.first);
        if (rollback) {
          if (rollback != recursion) {
            pmux2 = _pmg_backup_pmux2;
            return;
          }
          rollback = 0;
        }
      }
    }

    pmux2 = nullptr;
    pmux2 = _pmg_backup_pmux2;
  }

  // passes/pmgen/test_pmgen.pmg:187
  void block_16(int recursion YS_MAYBE_UNUSED) {
    Cell* const &eq YS_MAYBE_UNUSED = st_eqpmux.eq;
    const SigSpec &eq_inA YS_MAYBE_UNUSED = st_eqpmux.eq_inA;
    const SigSpec &eq_inB YS_MAYBE_UNUSED = st_eqpmux.eq_inB;
    const bool &eq_ne_signed YS_MAYBE_UNUSED = st_eqpmux.eq_ne_signed;
    Cell* const &ne YS_MAYBE_UNUSED = st_eqpmux.ne;
    Cell* const &pmux YS_MAYBE_UNUSED = st_eqpmux.pmux;
    Cell* const &pmux2 YS_MAYBE_UNUSED = st_eqpmux.pmux2;
    const int &pmux_slice_eq YS_MAYBE_UNUSED = st_eqpmux.pmux_slice_eq;
    const int &pmux_slice_ne YS_MAYBE_UNUSED = st_eqpmux.pmux_slice_ne;

#define reject do { goto rollback_label; } while(0)
#define accept do { accept_cnt++; on_accept(); if (rollback) goto rollback_label; } while(0)
#define finish do { rollback = -1; goto rollback_label; } while(0)
#define branch do { block_17(recursion+1); if (rollback) goto rollback_label; } while(0)
#define subpattern(pattern_name) do { block_subpattern_eqpmux_ ## pattern_name (recursion+1); if (rollback) goto rollback_label; } while(0)
    accept;

    block_17(recursion+1);
#undef reject
#undef accept
#undef finish
#undef branch
#undef subpattern

rollback_label:
    YS_MAYBE_UNUSED;
  }

  void block_17(int recursion YS_MAYBE_UNUSED) {
  }
};
